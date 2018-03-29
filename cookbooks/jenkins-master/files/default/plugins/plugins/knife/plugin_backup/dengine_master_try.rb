require 'chef/knife'
require "#{File.dirname(__FILE__)}/dengine_server_create"
require "#{File.dirname(__FILE__)}/dengine_elb_create"
require "#{File.dirname(__FILE__)}/dengine_elb_add_instance"

module Engine
  class DengineMasterTry < Chef::Knife

    def self.included(includer)
      includer.class_eval do
        deps do
          require 'chef/search/query'
        end
      end
    end

    deps do

      Engine::DengineServerCreate.load_deps
      Engine::DengineElbCreate.load_deps
      Engine::DengineElbAddInstance.load_deps

    end

    banner 'knife dengine master try (options)'

      option :build,
        :short => '-b BUILD_TOOL',
        :long => '--build BUILD_TOOL',
        :description => "The build tool required for the environment like MAVEN, GRADDLE etc.",
        :default => "maven"

      option :artifact,
        :short => '-a ARTIFACT_TOOL',
        :long => '--artifact ARTIFACT_TOOL',
        :description => "The artifactory tool required for the environment like JFROG, NEXUS etc.",
        :default => "jfrog"

      option :ci,
        :short => '-i CI_SERVER',
        :long => '--ci CI_SERVER',
        :description => "The CI tool required for the environment like JENKINS, BAMBOO, TEAMCITY etc.",
        :default => "jenkins"

      option :monitering,
        :short => '-m MONITERING_SERVER',
        :long => '--monitering MONITERING_SERVER',
        :description => "The monitering tool which helps to moniter the machines in the environment, for example SENSU, DATADOG etc.",
        :default => "jenkins"

      option :database,
        :short => '-d DATABASE',
        :long => '--database DATABASE',
        :description => "The database tool required for the environment.",
        :default => "mysql"

      option :webserver,
        :short => '-w WEBSERVER',
        :long => '--webserver WEBSERVER',
        :description => "The webserver required for the environment for example TOMCAT, APACHE2 etc.",
        :default => "tomcat"

      option :uat_db_tr,
        :long => '--uat_db_tr UAT_DB_FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine.",
        :default => "t2.micro"

      option :uat_wb_tr,
        :long => '--uat_wb_tr UAT_WB_FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine.",
        :default => "t2.micro"

      option :uat_wb_no,
        :long => '--uat_wb_no UAT_WB_SERVER_NUMBER',
        :description => "The number of servers that has to be created under the role web for UAT environment.",
        :default => 1

      option :prod_db_tr,
        :long => '--prod_db_tr PROD_DB_FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine.",
        :default => "t2.micro"

      option :prod_wb_tr,
        :long => '--prod_wb_tr PROD_WB_FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine.",
        :default => "t2.micro"

      option :prod_wb_no,
        :long => '--prod_wb_no PROD_WB_SERVER_NUMBER',
        :description => "The number of servers that has to be created under the role web for PROD environment.",
        :default => 1

    def run

      mngt_env = "MNGT"
      uat_env  = "UAT"
      prod_env = "PROD"
      mngt_flavor = "t2.micro"
      build = config[:build]
      artifact = config[:artifact]
      ci = config[:ci]
      monitering = config[:monitering]
      architecture = config[:architecture]
      database = config[:database]
      webserver = config[:webserver]
      uat_db_tr = config[:uat_db_tr]
      uat_wb_tr = config[:uat_wb_tr]
      value_uat = config[:uat_wb_no].to_i
      prod_db_tr = config[:prod_db_tr]
      prod_wb_tr = config[:prod_wb_tr]
      value_prod = config[:prod_wb_no].to_i

#-----------------------creation-of-load_balancers-uat-----------------------
 # creating load_balancers
      if value_uat > 1
       puts "creating ELB"
       create_elb("#{uat_env}ELB",uat_env)
      else
        puts "#{ui.color('Not creating load balancer for UAT as it was not opted', :cyan)}"
      end

#-----------------------creation-of-load_balancers-prod----------------------
 # creating load_balancers
      if value_prod > 1
        puts "creating ELB"
        create_elb("#{prod_env}ELB",prod_env)
      else
        puts "#{ui.color('Not creating load balancer for Production as it was not opted', :cyan)}"
      end

#---------------------------management-servers-------------------------------

      mngt_servers = Thread.new{create_mngt_servers(mngt_env,mngt_flavor,monitering,build,artifact,ci)}
      #mngt_servers.join

#------------------------------uat-servers-----------------------------------

      uat_servers = Thread.new{create_uat_server(value_uat,uat_env,database,webserver,uat_db_tr,uat_wb_tr)}
      #uat_servers.join

#----------------------------prod-servers------------------------------------

      prod_servers = Thread.new{create_prod_server(value_prod,prod_env,database,webserver,prod_db_tr,prod_wb_tr)}

      mngt_servers.join
      uat_servers.join
      prod_servers.join

#-------------------------Storing data of management server into data bag for future use------------------------------------

      mngt_ip = []
      n = mngt_servers.value.size-1
      mngt_servers.value.reverse.each {|i|
                               mngt_ip[n] = fetch_ipaddress(i)
                               n -=1
      }
      store_item('MONITERING-SERVER-URL',"#{mngt_ip[0]}:3000")
      store_item('BUILD-SERVER-IP', "#{mngt_ip[1]}")
      store_item('ARTIFACTORY-URL',"#{mngt_ip[2]}:8081/artifactory")
      store_item('JENKINS-URL',"#{mngt_ip[3]}:8080")

    end

    def create_machine(network,env,role,flavor)

      puts "I recived a value #{env} as a env"
      server_create = Engine::DengineServerCreate.new
      test = server_create.config[:environment]  = env
      test1 = server_create.config[:role]        = role
      test2 = server_create.config[:flavor]      = flavor
      test3 = server_create.config[:network]     = network

      id = server_create.run
      return id

    end

    def create_elb(elb_name,env)

      elb_create = Engine::DengineElbCreate.new
      elb_create.config[:name]              = elb_name
      elb_create.config[:env]               = env
      elb_create.config[:listener_lb_port]  = 80
      elb_create.config[:listener_protocol] = "HTTP"

      elb_create.run

    end

    def add_instance(elb_name,instance_id)

      instance_add = Engine::DengineElbAddInstance.new
      instance_add.config[:elb_name]    = elb_name
      instance_add.config[:instance_id] = instance_id

      instance_add.run

    end

    def fetch_instance_id(node)

      search = Chef::Knife::Search.new
      search.name_args = ['node', "name:#{node}"]
      out = search.run
      value = Array.new
      out.each do |node|
      value = node["ec2"]["instance_id"]
      end
      puts value
      return value

    end

    def fetch_ipaddress(node)

      search = Chef::Knife::Search.new
      search.name_args = ['node', "name:#{node}"]
      out = search.run
      ip = Array.new
      out.each do |node|
      ip = node["cloud_v2"]["public_ipv4"]
      end
      return ip

    end

    def store_item(key,value)

      if Chef::DataBag.list.key?("serverdatabag")
        puts ''
        puts "#{ui.color('Found databag for this', :cyan)}"
        puts "#{ui.color('Writing data in to the data bag', :cyan)}"
        puts ''
        serverdatabag = Chef::DataBagItem.load('serverdatabag', 'serverdatabag')
        serverdatabag.raw_data["#{key}"] = "#{value}"
        serverdatabag.save
        puts "#{ui.color('Data has been written in to databag successfully', :cyan)}"
      else
        puts ''
        puts "#{ui.color('Was not able to fine databag for this', :cyan)}"
        puts "#{ui.color('Hence creating databag', :cyan)}"
        puts ''
        users = Chef::DataBag.new
        users.name("serverdatabag")
        users.create
        data = {
               'id' => "serverdatabag",
               "#{key}" => "#{value}"
               }
        databag_item = Chef::DataBagItem.new
        databag_item.data_bag("serverdatabag")
        databag_item.raw_data = data
        databag_item.save
        puts "#{ui.color('Data bag created successfully and required data has been entered ', :cyan)}"
        puts ''
      end

    end

    def create_mngt_servers(mngt_env,mngt_flavor,monitering,build,artifact,ci)

      moni_node  = Thread.new{create_machine(mngt_env,"management",monitering,mngt_flavor)}
      build_node = Thread.new{create_machine(mngt_env,"management",build,mngt_flavor)}
      arti_node  = Thread.new{create_machine(mngt_env,"management",artifact,"t2.small")}
      ci_node    = Thread.new{create_machine(mngt_env,"management",ci,"t2.small")}

      moni_node.join
      build_node.join
      arti_node.join
      ci_node.join

      return moni_node.value,build_node.value,arti_node.value,ci_node.value

    end

    def create_uat_server(value_uat,uat_env,database,webserver,uat_db_tr,uat_wb_tr)
     # provisioning Database machine for uat environment
      udb = Thread.new{create_machine(uat_env,"development",database,uat_db_tr)}

      #------------mechanism to create instance and add it into load balancer UAT--------
      if value_uat > 1
        
        node_uat = []
        value_uat.times do |n|
        node_uat[n] =  Thread.new{create_machine(uat_env,"development-#{n}",webserver,uat_wb_tr)}
        end

        node_uat.each {|i|
                       i.join;
                        instance_id_uat = fetch_instance_id(i.value);
                        add_instance("#{uat_env}ELB",instance_id_uat)
        }

      else

      uwb = Thread.new{create_machine(uat_env,"development",webserver,uat_wb_tr)}
      uwb.join

      end

    udb.join
    end
	
    def create_prod_server(value_prod,prod_env,database,webserver,prod_db_tr,prod_wb_tr)

    # provisioning Database machine for production environment
      pdb = Thread.new{create_machine(prod_env,"production",database,prod_db_tr)}

      #------------mechanism to create instance for web and add it into load balancer PROD--------
      if value_prod > 1

        node_prod = []
        value_prod.times do |n|
        node_prod[n] =  Thread.new{create_machine(prod_env,"production-#{n}",webserver,prod_wb_tr)}
        end

        node_prod.each {|i|
                       i.join;
                        instance_id_prod = fetch_instance_id(i.value);
                        add_instance("#{prod_env}ELB",instance_id_prod)
        }

      else
        
      pwb = Thread.new{create_machine(prod_env,"production",webserver,prod_wb_tr)}
      pwb.join

      end

      pdb.join
    end

  end
end
