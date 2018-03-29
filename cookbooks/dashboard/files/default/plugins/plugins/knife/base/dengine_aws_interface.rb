require "#{File.dirname(__FILE__)}/dengine_client_base"
require "#{File.dirname(__FILE__)}/dengine_data_tresure"

module Engine
  class DengineAwsInterface < Chef::Knife

    include DengineClientBase
    include DengineDataTresure

    deps do
      require 'fog/aws'
      require 'readline'
      require 'chef/json_compat'
      require 'chef/knife/ec2_server_create'
      Chef::Knife::Ec2ServerCreate.load_deps
    end

#-----------------------------------creating VPC--------------------------------------
    def create_vpc(name,vpc_cidr)
      puts "#{ui.color('VPC creation has been started', :cyan)}"
      puts ''
      vpc = aws_connection_resource.create_vpc({ cidr_block: vpc_cidr })
      vpc_id = "#{vpc.vpc_id}"
      vpc.create_tags({ tags: [{ key: 'Name', value: "#{name}" }]})
      puts "#{ui.color('VPC creation in progress', :cyan)}"
      puts ''

      vpc.wait_until(max_attempts:10, delay:6) {|vpc| vpc.state == 'available' }
      puts "#{ui.color('VPC is created', :cyan)}"

      puts ''
      puts "========================================================="
      puts "#{ui.color('vpc-name', :magenta)}         : #{name}"
      puts "#{ui.color('vpc-id', :magenta)}           : #{vpc_id}"
      puts "========================================================="
      puts ''

      return vpc_id
    end

#------------------------------creating subnet----------------------------------

    def get_availability_zones
      zone = aws_connection_client.describe_availability_zones({})
      n = zone.availability_zones
      zones = []
      n.size.times do |a|
        zones[a] = n[a].zone_name
      end
      return zones
    end

    def create_subnet(cidr,vpc_id,name,zone)
      puts "#{ui.color('subnet creation has been started', :cyan)}"
      subnet = aws_connection_resource.create_subnet({vpc_id: vpc_id, cidr_block: cidr, availability_zone: zone})
      subnet.create_tags({ tags: [{ key: 'Name', value: "#{name}" }]})
      subnet_id = subnet.id
      puts "."
      puts "."
      puts "#{ui.color('SUBNET creation in progress', :cyan)}"
      puts ''

      subnet.wait_until(max_attempts:10, delay:6) {|subnet| subnet.state == 'available' }
      puts "#{ui.color('SUBNET is created', :cyan)}"

      puts ''
      puts "========================================================="
      puts "#{ui.color('subnet-name', :magenta)}      : #{name}"
      puts "#{ui.color('subnet-ids', :magenta)}       : #{subnet_id}"
      puts "========================================================="

      return subnet_id
    end

#----------------------------------creating IGW--------------------------------
    def create_igw(subnet_name,vpc_id)
      igw = aws_connection_resource.create_internet_gateway
      igw.create_tags({ tags: [{ key: 'Name', value: "#{subnet_name}" }]})
      igw.attach_to_vpc(vpc_id: vpc_id)
      gate_way_id = igw.id
      puts "."
      puts "."
      puts "#{ui.color('IGW creation is complete', :cyan)}"

      puts ''
      puts "========================================================="
      puts "#{ui.color('igw-name', :magenta)}         : #{subnet_name}"
      puts "#{ui.color('igw-id', :magenta)}           : #{gate_way_id}"
      puts "========================================================="


      return gate_way_id
    end

#----------------------creating route table------------------------
    def create_route_table(vpc_id,subnet_name,internet_gateway,subnet)
      puts "#{ui.color('creating route table for the VPC', :cyan)}"
      puts "."
      table = aws_connection_resource.create_route_table({ vpc_id: vpc_id})
      route_table_id = table.id
      table.create_tags({ tags: [{ key: 'Name', value: "#{subnet_name}" }]})
      # Chef::Log.debug 'Creating public route'
      puts "#{ui.color('Writing routes for the route table', :cyan)}"
      table.create_route({ destination_cidr_block: '0.0.0.0/0', gateway_id: internet_gateway })
      # Chef::Log.debug 'Associating route table with subnet'
      puts "."
      puts "#{ui.color('Attaching route table to the subnet', :cyan)}"
      table.associate_with_subnet({ subnet_id: subnet })
      puts ''

    end

#----------------------creating security group------------------------
    def create_security_group(name,vpc_id)
      security_group = aws_connection_client.create_security_group({
      dry_run: false,
        group_name: name,
        description: "security-group used by VPC #{name}",
        vpc_id: vpc_id
      })
      security_id = security_group.group_id
      aws_connection_client.authorize_security_group_ingress({dry_run: false, group_id: "#{security_id}", ip_protocol: "tcp", from_port: 0, to_port: 65535, cidr_ip: "0.0.0.0/0"})

      return security_id
    end

#---------------------Creation of Load Balancer-------------------------------

     def create_application_loadbalancer(name,subnet_id1,subnet_id2,security_group)
       elb = aws_connection_elb2.create_load_balancer({
          name: name,
          subnets: [subnet_id1,subnet_id2,],
          security_groups: security_group,
          scheme: "internet-facing",
          tags: [
            {
               key: "LoadBalancer",
               value: "#{name}-test",
            },
                ],
          ip_address_type: "ipv4",
          })
       lb_dns = elb.load_balancers[0].dns_name
       lb_arn = elb.load_balancers[0].load_balancer_arn

       return lb_dns,lb_arn
     end

     def create_classic_loadbalancer(name,subnet_id1,subnet_id2,security_group,protocol,loadbalancerport,vpc,instanceprotocol,instanceport)
       elb = aws_connection_elb.create_load_balancer({
          load_balancer_name: name,
          subnets: [subnet_id1,subnet_id2,],
          security_groups: security_group,
          scheme: "internet-facing",
          listeners: [
           {
             protocol: protocol, # required, accepts HTTP, HTTPS
             load_balancer_port: loadbalancerport, # required
             instance_protocol: instanceprotocol,
             instance_port: instanceport,
           },
           ],
          tags: [
            {
               key: "LoadBalancer",
               value: "#{name}-test",
            },
                ],
       })

      dns_lb = aws_connection_elb.describe_load_balancers({
        load_balancer_names: ["#{name}"],
      })

       lb_dns = dns_lb.load_balancer_descriptions[0].dns_name

       return lb_dns
     end

#---------------------Creation of Listener-------------------------------

     def create_application_listeners(elb_arn,protocol,loadbalancerport,elb_target_arn)
       listener = aws_connection_elb2.create_listener({
       load_balancer_arn: elb_arn, # required
       protocol: protocol, # required, accepts HTTP, HTTPS
       port: loadbalancerport, # required
       default_actions: [ # required
         {
           type: "forward", # required, accepts forward
           target_group_arn: elb_target_arn, # required
         },
         ],
         })
     end

     def create_classic_listeners(name,protocol,loadbalancerport,instanceprotocol,instanceport)
       listener = aws_connection_elb.create_load_balancer_listeners({
       load_balancer_name: elb_arn, # required
       listeners: [
       {
         protocol: protocol, # required, accepts HTTP, HTTPS
         load_balancer_port: loadbalancerport, # required
         instance_protocol: instanceprotocol, # required
         instance_port: instanceport, # required
       },
       ],
       })
     end

#---------------------Creation of Health check-------------------------------

    def create_health_check(elb_name,ping_path)
     health = aws_connection_elb.configure_health_check({
       health_check: {
       healthy_threshold: 2,
       interval: 30,
       target: "#{ping_path}",
       timeout: 3,
       unhealthy_threshold: 2,
       },
       load_balancer_name: "#{elb_name}", 
    })
    end

#---------------------Creation of Target Groups-------------------------------

    def create_target_group(name,protocol,loadbalancerport,vpc)
      target = aws_connection_elb2.create_target_group({
      name: "#{name}", # required
      protocol: protocol, # required, accepts HTTP, HTTPS
      port: loadbalancerport, # required
      vpc_id: vpc, # required
      health_check_protocol: protocol, # accepts HTTP, HTTPS
      health_check_port: "traffic-port",
      health_check_path: "/index.html",
      health_check_interval_seconds: 30,
      health_check_timeout_seconds: 5,
      healthy_threshold_count: 5,
      unhealthy_threshold_count: 2,
      matcher: {
        http_code: "200", # required
      },
      })
      elb_target = target.target_groups[0].target_group_arn
      return elb_target
    end

#----------------adding instances to load balancers--------------

    def register_server_to_load_balancers(elb_name,instanceid,type)

      puts "#{ui.color('Adding instances to load balancer', :cyan)}"
      puts "."
      puts "#{ui.color('Adding process is in progress', :cyan)}"
      puts "#{ui.color('Checking the requirements', :cyan)}"

      # adding instances to application load balancers
      if type == "application"
        puts ""
        puts "#{ui.color('Fetching arn of target group to add instance', :cyan)}"
        begin
          target_arn = fetch_data("loadbalancers",elb_name,"TARGET-GROUP-ARN")
#          puts "#{target_arn}"
          arn = target_arn[0].to_s
#          puts "#{arn}"
        rescue
          puts ""
          Chef::Log.error "I encoutered error in getting arn of target group from databag, check if databag or databag_item exists"
        end
        aws_connection_elb2.register_targets({
         target_group_arn: arn, 
         targets: [
         {
           id: instanceid,
         },
         ],
        })
        puts "#{ui.color('Instance is successfully added to loadbalancer', :cyan)}"

      # adding instances to load balancers
      elsif type == "network"
        aws_connection_elb.register_instances_with_load_balancer({
         load_balancer_name: "#{elb_name}",
         instances: [
         {
           instance_id: instanceid,
         },
         ],
        })
        puts "#{ui.color('Instance is successfully added to loadbalancer', :cyan)}"

      elsif (type.nil?)
        puts "#{ui.color('I am sensing something wrong here', :magenta)}"
        puts "."
        Chef::Log.error "You have not provided the loadbalancer type for me, I cannot add instances/server to the pool without it"
        puts "#{ui.color('I am quitting here', :magenta)}"
        exit

      else
        puts ""
        puts "#{ui.color('I do not know the type of loadbalancer you have entered, I am quitting', :magenta)}"
        exit

      end

    end

#--------------------------creation of server-----------------------------

    def create_server(node_name,runlist,env,security_group,image,ssh_user,ssh_key_name,identify_file,region,flavor,chef_env)

      create = Chef::Knife::Ec2ServerCreate.new

      create.config[:flavor]              = flavor
      create.config[:image]               = image
      create.config[:security_group_ids]  = security_group
      create.config[:chef_node_name]      = node_name
      create.config[:ssh_user]            = ssh_user
      create.config[:ssh_port]            = 22
      create.config[:ssh_key_name]        = ssh_key_name
      create.config[:identity_file]       = identify_file
      create.config[:run_list]            = runlist
      create.config[:subnet_id]           = env
      create.config[:associate_public_ip] = true
      create.config[:region]              = region
      create.config[:environment]         = chef_env
      create.config[:bootstrap_version]   = '12.21.31'

      value = create.run

      puts "-------------------------"
      puts "NODE-NAME: #{node_name}"
      puts "ENV      : #{chef_env}"
      puts "-------------------------"

    end

#-------------------------------server backup---------------------------

    def create_image(instance_id,image_name,descrip)

      puts "#{ui.color('Started capturing image of the server with ID', :cyan)}:  #{instance_id}"
      puts "."
      puts "#{ui.color('Capturing image in progress', :cyan)}"
      puts "."
      image = aws_connection_client.create_image(instance_id: "#{instance_id}", name: "#{image_name}", description: "#{descrip}",)
      image_id = image.image_id
      puts "#{ui.color('Image successfully captured', :cyan)}"
      aws_connection_client.create_tags({ resources: ["#{image_id}"], tags: [{ key: 'Name', value: "#{image_name}" }]})
      puts ''
      puts "========================================================="
      puts "#{ui.color('image-name', :magenta)}       : #{image_name}"
      puts "#{ui.color('image-id', :magenta)}         : #{image_id}"
      puts "========================================================="
      puts ''

    end

  end
end
