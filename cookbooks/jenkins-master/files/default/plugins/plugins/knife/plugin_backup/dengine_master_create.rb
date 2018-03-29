require 'chef/knife'
require "#{File.dirname(__FILE__)}/dengine_master_base"
require "#{File.dirname(__FILE__)}/dengine_server_create"
require "#{File.dirname(__FILE__)}/dengine_elb_create"
require "#{File.dirname(__FILE__)}/dengine_elb_add_instance"
require "#{File.dirname(__FILE__)}/dengine_update_databag"

module Engine
  class DengineMasterCreate < Chef::Knife

    include DengineMasterBase

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
      DengineApp::DengineUpdateDatabag.load_deps

    end

    banner 'knife dengine master create (options)'

    option :app,
        :long => '--app APP_NAME',
        :description => "The name of the application for which the environment is being setup",
        :default => "java"

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

    option :monitoring,
        :short => '-m MONITORING_SERVER',
        :long => '--monitoring MONITORING_SERVER',
        :description => "The monitoring tool which helps to moniter the machines in the environment, for example SENSU, DATADOG etc.",
        :default => "sensu"

    option :log_management,
        :short => '-l LOG_MANAGEMENT_SERVER',
        :long => '--log_management LOG_MANAGEMENT_SERVER',
        :description => "The tool required to manage the log of the servers in the environment. For example SPLUNK etc.",
        :default => "splunk"

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

    option :dev_db_tr,
        :long => '--dev_db_tr DEV_DB_FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine.",
        :default => "t2.micro"

    option :dev_wb_tr,
        :long => '--dev_wb_tr UAT_WB_FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine.",
        :default => "t2.micro"

    option :tst_db_tr,
        :long => '--tst_db_tr DEV_DB_FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine.",
        :default => "t2.micro"

    option :tst_wb_tr,
        :long => '--tst_wb_tr UAT_WB_FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine.",
        :default => "t2.micro"

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

      app = config[:app]

      mngt_env = "management"
      mngt_network = "MNGT"
      mngt_flavor = "t2.micro"

      dev_env  = "development"
      test_env = "testing"
      uat_env  = "acceptance"
      uat_network  = "UAT"

      prod_env = "production"
      prod_network = "PROD"

      build = config[:build]
      artifact = config[:artifact]
      ci = config[:ci]
      log_node = config[:log_management]
      monitoring = config[:monitoring]
      architecture = config[:architecture]
      database = config[:database]
      webserver = config[:webserver]
      dev_db_tr = config[:dev_db_tr]
      dev_wb_tr = config[:dev_wb_tr]
      tst_db_tr = config[:tst_db_tr]
      tst_wb_tr = config[:tst_wb_tr]
      uat_db_tr = config[:uat_db_tr]
      uat_wb_tr = config[:uat_wb_tr]
      value_uat = config[:uat_wb_no].to_i
      prod_db_tr = config[:prod_db_tr]
      prod_wb_tr = config[:prod_wb_tr]
      value_prod = config[:prod_wb_no].to_i

      create_application_data_bag(app)
#-----------------------creation-of-load_balancers-uat-----------------------
 # creating load_balancers
      if value_uat > 1
       puts "creating ELB"
       elbu = create_elb(app,"#{app}-#{uat_env}-ELB",uat_network,webserver)
      else
        puts "#{ui.color('Not creating load balancer for UAT as it was not opted', :cyan)}"
      end

#-----------------------creation-of-load_balancers-prod----------------------
 # creating load_balancers
      if value_prod > 1
        puts "creating ELB"
        elbp = create_elb(app,"#{app}-#{prod_env}-ELB",prod_network,webserver)
      else
        puts "#{ui.color('Not creating load balancer for Production as it was not opted', :cyan)}"
      end

#---------------------------management-servers-------------------------------

      mngt_servers = Thread.new{create_mngt_servers(app,mngt_network,mngt_env,mngt_flavor,monitoring,build,artifact,ci,log_node)}

#------------------------------dev-servers-----------------------------------

      dev_servers = Thread.new{create_dev_server(app,uat_network,dev_env,database,webserver,dev_db_tr,dev_wb_tr)}

#------------------------------test-servers-----------------------------------

      test_servers = Thread.new{create_test_server(app,uat_network,test_env,database,webserver,tst_db_tr,tst_wb_tr)}

#------------------------------uat-servers-----------------------------------

      uat_servers = Thread.new{create_uat_server(app,value_uat,uat_network,uat_env,database,webserver,uat_db_tr,uat_wb_tr)}

#----------------------------prod-servers------------------------------------

      prod_servers = Thread.new{create_prod_server(app,value_prod,prod_network,prod_env,database,webserver,prod_db_tr,prod_wb_tr)}

      dev_servers.join
      test_servers.join
      uat_servers.join
      prod_servers.join
      mngt_servers.join

#-------------------------Storing data of management server into data bag for future use------------------------------------

      mngt_ip = {}
      mngt_servers.value.each {|i|
                               ip = fetch_ipaddress(i);
                               mngt_ip.store(i,ip);
      }

      store_item(app,"#{mngt_ip.keys[0]}","http://#{mngt_ip.values[0]}:3000","management_servers","monitoring")
      sleep(5)
      store_item(app,"#{mngt_ip.keys[1]}","#{mngt_ip.values[1]}","management_servers","build")
      sleep(5)
      store_item(app,"#{mngt_ip.keys[2]}","http://#{mngt_ip.values[2]}:8081/artifactory","management_servers","artifactory")
      sleep(5)
      store_item(app,"#{mngt_ip.keys[3]}","http://#{mngt_ip.values[3]}:8080","management_servers","jenkins")
      sleep(5)
      store_item(app,"#{mngt_ip.keys[4]}","http://#{mngt_ip.values[4]}","management_servers","splunk")

      save_server_details(app,dev_env,dev_servers.value)
      save_server_details(app,test_env,test_servers.value)

#------------------------storing UAT anf PROD servers---------------------------------------
      if value_prod || value_uat > 1

        if (value_prod > 1) && (value_uat == 1)

          store_item(app,"#{prod_servers.value[1]}","#{fetch_ipaddress("#{prod_servers.value[1]}")}","production_servers","mysql")
          sleep(5)
          uat_ip = {}
          m = prod_servers.value[0].size-1
          prod_servers.value[0].each {|i|
                                      puts "from prod_servers.each function and I got #{i}";
                                      ip = fetch_ipaddress(i);
                                      store_item(app,"#{i}","http://#{ip}:8080","production_servers","tomcat#{m}");
                                  m -=1;
                                  sleep(5)
          }
          save_server_details(app,uat_env,uat_servers.value)
          store_elb_details_in_serverdetails(elbp,"#{app}_production_servers")

        elsif (value_prod == 1) && (value_uat > 1)

          store_item(app,"#{uat_servers.value[1]}","#{fetch_ipaddress("#{uat_servers.value[1]}")}","acceptance_servers","mysql")
          sleep(5)
          uat_ip = {}
          n = uat_servers.value[0].size-1
          uat_servers.value[0].each {|i|
                                     puts "from uat_servers.each function and I got #{i}";
                                     ip = fetch_ipaddress(i);
                                     store_item(app,"#{i}","http://#{ip}:8080","acceptance_servers","tomcat#{n}");
                                     n -=1;
                                     sleep(5)
          }
          save_server_details(app,prod_env,prod_servers.value)
          store_elb_details_in_serverdetails(elbu,"#{app}_acceptance_servers")

        elsif (value_prod > 1) && (value_uat > 1)

          store_uat_prod_server_details(app,uat_servers,prod_servers)
          store_elb_details_in_serverdetails(elbu,"#{app}_acceptance_servers")
          store_elb_details_in_serverdetails(elbp,"#{app}_production_servers")
          
        else

          puts "#{ui.color('Not recording data of UAT and PROD server as you specified', :cyan)}"

        end

      else

        save_server_details(app,uat_env,uat_servers.value)
        save_server_details(app,prod_env,prod_servers.value)
#--------------------------------------------------------------------------------------------

      end


    end

    def create_machine(app,network,env,role,flavor,id)

      server_create = Engine::DengineServerCreate.new
      server_create.config[:app]          = app
      server_create.config[:id]           = id
      server_create.config[:environment]  = env
      server_create.config[:role]         = role
      server_create.config[:flavor]       = flavor
      server_create.config[:network]      = network

      name = server_create.run
      return name

    end

    def create_elb(app,elb_name,network,webserver)

      elb_create = Engine::DengineElbCreate.new
      elb_create.config[:app]               = app
      elb_create.config[:name]              = elb_name
      elb_create.config[:network]           = network
      if webserver == 'tomcat'
        elb_create.config[:listener_lb_port]  = 8080
      else
        elb_create.config[:listener_lb_port]  = 80
      end
      elb_create.config[:listener_protocol] = "HTTP"

      elb = elb_create.run
      return elb

    end

    def add_instance(elb_name,instance_id)

      instance_add = Engine::DengineElbAddInstance.new
      instance_add.config[:elb_name]    = elb_name
      instance_add.config[:instance_id] = instance_id

      instance_add.run

    end

#----------------- storing values in data bag-------------------

    def store_item(app,name,url,servers_category,servers_type)

      puts "+++++++++++++++++++++++++++++++++++++++"
      puts "#{name}"
      puts "#{url}"
      puts "#{servers_category}"
      puts "#{servers_type}"
      puts "+++++++++++++++++++++++++++++++++++++++"
      data = DengineApp::DengineUpdateDatabag.new
      data.config[:app_name]         = app
      data.config[:name]             = name
      data.config[:url]              = url
      data.config[:servers_category] = servers_category
      data.config[:servers_type]     = servers_type

      data.run

    end

#---------------------------------------------------------------

    def create_mngt_servers(app,mngt_network,mngt_env,mngt_flavor,monitoring,build,artifact,ci,log_node)

      id = 0
      moni_node  = Thread.new{create_machine(app,mngt_network,mngt_env,monitoring,mngt_flavor,id)}
      build_node = Thread.new{create_machine(app,mngt_network,mngt_env,build,mngt_flavor,id)}
      arti_node  = Thread.new{create_machine(app,mngt_network,mngt_env,artifact,"t2.small",id)}
      ci_node    = Thread.new{create_machine(app,mngt_network,mngt_env,ci,"t2.small",id)}
      logm_node  = Thread.new{create_machine(app,mngt_network,mngt_env,log_node,"t2.small",id)}

      moni_node.join
      build_node.join
      arti_node.join
      ci_node.join
      logm_node.join

      return moni_node.value,build_node.value,arti_node.value,ci_node.value,logm_node.value

    end

    def create_uat_server(app,value_uat,uat_network,uat_env,database,webserver,uat_db_tr,uat_wb_tr)
     # provisioning Database machine for uat environment
      id = 0
      udb = Thread.new{create_machine(app,uat_network,uat_env,database,uat_db_tr,id)}

      #------------mechanism to create instance and add it into load balancer UAT--------
      if value_uat > 1

        node_uat = []
        value_uat.times do |n|
        node_uat[n] =  Thread.new{create_machine(app,uat_network,uat_env,webserver,uat_wb_tr,"#{n}")}
        end

        u = value_uat-1
        uat = []
        node_uat.each {|i|
                       i.join;
                       uat[u] = i.value;
                       u -=1;
                       instance_id_uat = fetch_instance_id(i.value);
                       add_instance("#{app}-#{uat_env}-ELB",instance_id_uat)
        }

      else

      uwb = Thread.new{create_machine(app,uat_network,uat_env,webserver,uat_wb_tr,id)}
      uwb.join

      end

      udb.join

      if value_uat > 1
        return uat,udb.value
      else
        return uwb.value,udb.value
      end

    end

    def create_prod_server(app,value_prod,prod_network,prod_env,database,webserver,prod_db_tr,prod_wb_tr)
    # provisioning Database machine for production environment
      id = 0
      pdb = Thread.new{create_machine(app,prod_network,prod_env,database,prod_db_tr,id)}

      #------------mechanism to create instance for web and add it into load balancer PROD--------
      if value_prod > 1

        node_prod = []
        value_prod.times do |n|
        node_prod[n] =  Thread.new{create_machine(app,prod_network,prod_env,webserver,prod_wb_tr,"#{n}")}
        end

        u = value_prod-1
        prod = []
        node_prod.each {|i|
                        i.join;
                        prod[u] = i.value;
                        u -=1;
                        instance_id_prod = fetch_instance_id(i.value);
                        add_instance("#{app}-#{prod_env}-ELB",instance_id_prod)
        }

      else

      pwb = Thread.new{create_machine(app,prod_network,prod_env,webserver,prod_wb_tr,id)}
      pwb.join

      end

      pdb.join
      if value_prod > 1
        return prod,pdb.value
      else
        return pwb.value,pdb.value
      end

    end

    def create_dev_server(app,uat_network,uat_env,database,webserver,dev_db_tr,dev_wb_tr)

      id = 0
      # provisioning Database machine for development environment
      ddb = Thread.new{create_machine(app,uat_network,uat_env,database,dev_db_tr,id)}

      # mechanism to create instance for web in development environment
      dwb = Thread.new{create_machine(app,uat_network,uat_env,webserver,dev_wb_tr,id)}

      ddb.join
      dwb.join
      return dwb.value,ddb.value

    end

    def create_test_server(app,uat_network,uat_env,database,webserver,tst_db_tr,tst_wb_tr)

      id = 0
      # provisioning Database machine for testing environment
      tdb = Thread.new{create_machine(app,uat_network,uat_env,database,tst_db_tr,id)}

      # mechanism to create instance for web in testing environment
      twb = Thread.new{create_machine(app,uat_network,uat_env,webserver,tst_wb_tr,id)}

      tdb.join
      twb.join
      return twb.value,tdb.value

    end

  end
end
