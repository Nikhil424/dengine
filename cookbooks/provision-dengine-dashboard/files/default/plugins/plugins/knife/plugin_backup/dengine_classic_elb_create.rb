require 'chef/knife'
require "#{File.dirname(__FILE__)}/dengine_elb_base"
require "#{File.dirname(__FILE__)}/dengine_server_base"

module Engine
    class DengineClassicElbCreate < Chef::Knife

      include DengineElbBase
      include DengineServerBase

      banner 'knife dengine classic elb create (options)'

      option :listener_protocol,
        :long => '--listener-protocol HTTP',
        :description => 'Listener protocol (available: HTTP, HTTPS, TCP, SSL) (default HTTP)',
        :default => 'HTTP'

      option :listener_instance_protocol,
        :long => '--listener-instance-protocol HTTP',
        :description => 'Instance connection protocol (available: HTTP, HTTPS, TCP, SSL) (default HTTP)',
        :default => 'HTTP'

      option :listener_lb_port,
        :long => '--listener-lb-port 80',
        :description => 'Listener load balancer port (default 80)',
        :default => 80

      option :listener_instance_port,
        :long => '--listener-instance-port 80',
        :description => 'Instance port to forward traffic to (default 80)',
        :default => 80

      option :ssl_certificate_id,
        :long => '--ssl-certificate-id SSL-ID',
        :description => 'ARN of the server SSL certificate'

      option :app,
        :short => '-a APP__NAME',
        :long => '--app APP_NAME',
        :description => "The name of the application for which the environment is being setup",
        :default => "java"

      option :name,
        :short => '-n ELB_NAME',
        :long => '--name ELB_NAME',
        :description => "The name of the elastic load balancer that has to be created"

      option :network,
        :long => '--network NETWORK_NAME',
        :description => "The name of the network in which elastic load balancer has to be created"

      option :ping_path,
        :short => '-p PING_PATH',
        :long => '--ping_path PING_PATH',
        :description => "The ping path to configure the health check for the classic loadbalancers. It looks something like: HTTP:80/index.html"


     def run

#       puts "Hi this is from knife ELB PLUGIN"
       app = config[:app]
       name = config[:name]
       env = config[:network]
       protocol = config[:listener_protocol]
       instanceprotocol = config[:listener_instance_protocol]
       loadbalancerport = config[:listener_lb_port]
       instanceport = config[:listener_instance_port]
       sslcertificateid = config[:ssl_certificate_id]
#       puts "#{env}"
       subnet = get_subnet_id(env)
       vpc = get_vpc_id(env)
       sg_group = get_security_group(env)
       subnet_id1 = subnet.first
       subnet_id2 = subnet.last
       security_group = ["#{sg_group}"]

       if Chef::DataBag.list.key?("loadbalancers")
#         puts "#{name}"
         puts ''
         puts "#{ui.color('Found databag for this', :cyan)}"
         puts "#{ui.color('Searching data for current application in to the data bag', :cyan)}"
         puts ''
         query = Chef::Search::Query.new
         query_value = query.search(:loadbalancers, "id:#{name}")
         if query_value == 0

           puts ""
           puts "#{ui.color("The loadbalancer by name #{name} already exists please check", :cyan)}"
           puts "#{ui.color("Hence we are quiting ", :cyan)}"
           puts ""
           exit

         else

           elb = create_elb(app,name,subnet_id1,subnet_id2,security_group,protocol,loadbalancerport,vpc,instanceprotocol,instanceport)

        end

      else

        elb = create_elb(app,name,subnet_id1,subnet_id2,security_group,protocol,loadbalancerport,vpc,instanceprotocol,instanceport)

      end

      return elb

     end
#---------------------Creation of Load Balancer-------------------------------

     def create_loadbalancer(name,subnet_id1,subnet_id2,security_group,protocol,loadbalancerport,vpc,instanceprotocol,instanceport)
       elb = connection_elb.create_load_balancer({
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

      dns_lb = connection_elb.describe_load_balancers({
        load_balancer_names: ["#{name}"],
      })

       lb_dns = dns_lb.load_balancer_descriptions[0].dns_name

       return lb_dns
     end

#---------------------Creation of Listener-------------------------------

     def create_listeners(name,protocol,loadbalancerport,instanceprotocol,instanceport)
       listener = connection_elb.create_load_balancer_listeners({
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

    def create_health_check(elb_name)
     health = connection_elb.configure_health_check({
       health_check: {
       healthy_threshold: 2,
       interval: 30,
       target: config[:ping_path],
       timeout: 3,
       unhealthy_threshold: 2,
       },
       load_balancer_name: "#{elb_name}", 
    })
    end
#-----------------creation of complete elb stack--------------

     def create_elb(app,name,subnet_id1,subnet_id2,security_group,protocol,loadbalancerport,vpc,instanceprotocol,instanceport)

        # creation of load balancer
        puts "#{ui.color('creating load balancer for the environment', :cyan)}"
        elb_details = create_loadbalancer(name,subnet_id1,subnet_id2,security_group,protocol,loadbalancerport,vpc,instanceprotocol,instanceport)
        elb_dns = elb_details
        puts "#{ui.color('load balancer created', :cyan)}"
        puts ""

        # creation of listeners
#        puts "#{ui.color('creating listeners for the load balancer created', :cyan)}"
#        lb_listeners = create_listeners(name,protocol,loadbalancerport,instanceprotocol,instanceport)
#        puts "#{ui.color('listeners created', :cyan)}"
#        puts ""
        # creation of health checks
        puts "#{ui.color('creating health checks for the load balancer created', :cyan)}"
        puts "."
        lb_health_checks = create_health_check(name)
        puts "."
        puts "#{ui.color('Health check created successfully', :cyan)}"
        puts ""


        # creating and adding data to data_bag
        store_elb_data(app,name,elb_dns)

        # printing details of the loadbalancers
        puts "#{ui.color('Printing details', :magenta)}"
        puts "First subnet value #{subnet_id1}"
        puts "First subnet value #{subnet_id2}"

        return elb_dns

     end
#---------------storing data------------------------------
     def store_elb_data(app,name,elb_dns)

       if Chef::DataBag.list.key?("loadbalancers")
         puts ''
         puts "#{ui.color('Found databag for this', :cyan)}"
         puts "#{ui.color('Writing data in to the data bag item', :cyan)}"
         puts ''

         data = {
                'id' => "#{name}",
                'APP-NAME' => "#{app}",
                'ELB-NAME' => "#{name}",
                'ELB_DNS' => "#{elb_dns}"
                }
         dengine_item = Chef::DataBagItem.new
         dengine_item.data_bag("loadbalancers")
         dengine_item.raw_data = data
         dengine_item.save

         puts "#{ui.color('Data has been written in to databag successfully', :cyan)}"
       else
         puts ''
         puts "#{ui.color('Was not able to fine databag for this', :cyan)}"
         puts "#{ui.color('Hence creating databag', :cyan)}"
         puts ''
         users = Chef::DataBag.new
         users.name("loadbalancers")
         users.create
         data = {
                'id' => "#{name}",
                'APP-NAME' => "#{app}",
                'ELB-NAME' => "#{name}",
                'ELB_DNS' => "#{elb_dns}"
                }
         databag_item = Chef::DataBagItem.new
         databag_item.data_bag("loadbalancers")
         databag_item.raw_data = data
         databag_item.save
       end

     end

#------------------------------------------------------------------------------
  end
end
