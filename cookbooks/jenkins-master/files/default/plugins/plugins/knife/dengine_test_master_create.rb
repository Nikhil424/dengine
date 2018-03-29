require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_master_base"

module Engine
  class DengineTestMasterCreate < Chef::Knife

    include DengineMasterBase

    deps do
      require 'chef/search/query'
      require "#{File.dirname(__FILE__)}/dengine_load_balancer_create"
      Engine::DengineLoadBalancerCreate.load_deps
      require "#{File.dirname(__FILE__)}/dengine_add_instance_loadbalancer"
      Engine::DengineAddInstanceLoadbalancer.load_deps
      require "#{File.dirname(__FILE__)}/dengine_server_create"
      Engine::DengineServerCreate.load_deps
      require "#{File.dirname(__FILE__)}/dengine_add_instance_loadbalancer"
      Engine::DengineAddInstanceLoadbalancer.load_deps
    end

    banner 'knife dengine test master create (options)'

    option :cloud,
        :long => '--cloud CLOUD_PROVIDER_NAME',
        :description => "The name of the cloud provider for ex: aws, azure, google, openstack etc"

    option :resource_group,
        :long => '--resource-group-name RESOURCE_GROUP_NAME',
        :description => "The name of Resource group in which the network that has to be created",
        :default => "Dengine"

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

    option :in_memory_db,
        :long => '--in_memory_db IN_MEMORY_DATABASE',
        :description => "The in memory database tool required for the environment, like redis.",
        :default => "redis"

    option :search_engine,
        :long => '--search_engine SEARCH_ENGINE',
        :description => "The search engine tool required for the environment, like elasticsearch or solar.",
        :default => "elasticsearch"

    option :mngt_server_flavour,
        :long => '--mngt-server-flavour MANAGEMENT_SERVER_FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine.",
        :default => "t2.micro"

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

    option :uat_in_db_tr,
        :long => '--uat_in_db_tr UAT_IN_MEMORY_BATABASE_FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine.",
        :default => "t2.micro"

    option :uat_search_tr,
        :long => '--uat_search_tr UAT_SEARCH_ENGINE_FLAVOR',
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

   option :prod_in_db_tr,
        :long => '--prod_in_db_tr PROD_IN_MEMORY_BATABASE_FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine.",
        :default => "t2.micro"

    option :prod_search_tr,
        :long => '--prod_search_tr PROD_SEARCH_ENGINE_FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine.",
        :default => "t2.micro"

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

    option :lb_name,
        :long => '--lb-name LOAD_BALANCE_NAME',
        :description => "The name of the load balancer by which the load balancer has to be created (This is exclusively for azure)."

    option :storage_account,
        :long => '--storage-account STORAGE_ACCOUNT',
        :description => "The name of the storage account in which the VMs has to be created (This is exclusively for azure)."

    def run

      @app = config[:app]
      @mngt_network = "#{config[:cloud]}_MNGT"
      @mngt_env = "management"
      @mngt_flavor = config[:mngt_server_flavour]
      @dev_env = "development"
      @test_env = "testing"
      @uat_network = "#{config[:cloud]}_UAT"
      @uat_env = "acceptance"
      @value_uat = config[:uat_wb_no].to_i
      @value_prod = config[:prod_wb_no].to_i
      @prod_network = "#{config[:cloud]}_PROD"
      @prod_env = "production"

      create_application_data_bag(@app)

      if config[:cloud] == "google"
        puts "#{ui.color('we are in alfa, soon we will be here', :cyan)}"
        ui.confirm("we are in alfa, certain resources cannot be created in the cloud provider you chose do you want to continue? ")
        exit
      elsif config[:cloud] == "openstack"
        puts "#{ui.color('we are in alfa, soon we will be here', :cyan)}"
        exit
        @client = ''
      elsif (config[:cloud] == "azure") || (config[:cloud] == "aws")
        puts ""
        puts "#{ui.color('We are creating the stack that you selected, set back and relax', :cyan)}"
        puts ""
        create_stack
        puts "#{ui.color('The stack creation is complete', :cyan)}"
        puts ""
        puts "#{ui.color('Thankyou for using us refer the dashboard for more info', :cyan)}"
      else (config[:cloud].nil?)
        puts ""
        puts "#{ui.color('You did not pass a cloud provider, can you please check back and re run', :cyan)}"
        puts ""
        exit
      end

    end

    def create_stack

      puts "#{ui.color('The stack creation was initiated', :cyan)}"
      puts ""

#-----------------------creation-of-load_balancers-uat-----------------------
 # creating load_balancers
      if @value_uat > 1
        if config[:cloud] == "aws"
         @elbu = create_lb(@app,"#{@app}-#{@uat_env}",@uat_network,"network","")
        elsif config[:cloud] == "azure"
         @elbu = create_lb(@app,"#{@app}-#{@uat_env}",@uat_network,"network","#{config[:resource_group]}")
        end
      else
        puts "#{ui.color('Not creating load balancer for UAT as it was not opted', :cyan)}"
      end
      sleep(5)

      puts ""
      puts "#{ui.color('The stack creation is in progress', :cyan)}"
      puts ""

#---------------------------management-servers-------------------------------

      uat_servers = Thread.new{create_uat_server(@app,@value_uat,@uat_network,@uat_env)}

      uat_servers.join

      puts ""
      puts "#{ui.color('The stack creation is complete', :cyan)}"
      puts ""

    end

    def create_machine(app,network,env,role,flavor,id,lb_name)

      server_create = Engine::DengineServerCreate.new
      server_create.config[:machine_user]   = "ubuntu"
      server_create.config[:app]            = app
      server_create.config[:id]             = id
      server_create.config[:environment]    = env
      server_create.config[:role]           = role
      server_create.config[:flavor]         = flavor
      server_create.config[:network]        = network
      server_create.config[:cloud]          = config[:cloud]
      server_create.config[:lb_name]        = lb_name unless lb_name.nil?
      server_create.config[:resource_group] = config[:resource_group] unless config[:resource_group].nil?
      server_create.config[:storage_account]= config[:storage_account] unless config[:storage_account].nil?

      name = server_create.run

      node_ip = fetch_ipaddress(name)
      if (config[:cloud] == "aws") && (%w[web tomcat].include?(role))
        instance_id = fetch_instance_id(name)
        if env == "production"
          add_instance(@elbp,instance_id)
        elsif env == "acceptance"
          add_instance(@elbu,instance_id)
        else
        end
      end

      puts "#{ui.color('The data storing procedure of the servers which are part of stacks is started', :cyan)}"
      store_item(name,get_url(role,node_ip),"#{@app}_#{env}_servers",get_server_type(role,id))
      sleep(5)
      puts "#{ui.color('The data storing procedure is complete', :cyan)}"
      puts ""

    end

#-----------------------------load balancer creation---------------------------

    def create_lb(app,elb_name,network,type,resource_group)

      elb_create = Engine::DengineLoadBalancerCreate.new
      elb_create.config[:app]                 = app
      elb_create.config[:name]                = elb_name
      elb_create.config[:network]             = network
      if config[:webserver] == 'tomcat'
        elb_create.config[:ping_path]  = "HTTP:8080/index.html"
        elb_create.config[:listener_lb_port]  = 8080
        elb_create.config[:listener_instance_port] = 8080
      elsif
        elb_create.config[:ping_path]  = "HTTP:80/index.html"
        elb_create.config[:listener_lb_port]  = 80
        elb_create.config[:listener_instance_port] = 80
      end
      elb_create.config[:listener_instance_protocol] = "HTTP"
      elb_create.config[:listener_protocol]   = "HTTP"
      elb_create.config[:cloud]               = config[:cloud]
      elb_create.config[:type]                = type
      elb_create.config[:resource_group]      = resource_group unless resource_group.nil?

      elb = elb_create.run
      return elb

    end

#------adding servers to load balancers(exclusively for aws)--------

    def add_instance(elb_name,instance_id)

      instance_add = Engine::DengineAddInstanceLoadbalancer.new
      instance_add.config[:elb_name]    = elb_name
      instance_add.config[:instance_id] = instance_id
      instance_add.config[:type]        = "network"
      instance_add.config[:cloud]       = config[:cloud]

      instance_add.run

    end

#---------------------------------------------------------------

    def create_mngt_servers(app,mngt_network,mngt_env,mngt_flavor)

      #---the "" indicates that no load balancer name is being passed----
      id = 0
      moni_node  = Thread.new{create_machine(app,mngt_network,mngt_env,config[:monitoring],mngt_flavor,id,"null")}
#      build_node = Thread.new{create_machine(app,mngt_network,mngt_env,config[:build],mngt_flavor,id,"")}
#      arti_node  = Thread.new{create_machine(app,mngt_network,mngt_env,config[:artifact],mngt_flavor,id,"")}
#      ci_node    = Thread.new{create_machine(app,mngt_network,mngt_env,config[:ci],mngt_flavor,id,"")}
#      logm_node  = Thread.new{create_machine(app,mngt_network,mngt_env,config[:log_management],mngt_flavor,id,"")}

      moni_node.join
#      build_node.join
#      arti_node.join
#      ci_node.join
#     logm_node.join

    end

    def create_uat_server(app,value_uat,uat_network,uat_env)
     # provisioning Database machine for uat environment
      id = 0
      udb = Thread.new{create_machine(app,uat_network,uat_env,config[:database],config[:uat_db_tr],id,"null")}

      #------------mechanism to create instance and add it into load balancer UAT--------
      if @value_uat > 1

        puts "the @elbu value is: #{@elbu}"
        uwb = []
        @value_uat.times do |n|
        uwb[n] = Thread.new{create_machine(app,uat_network,uat_env,config[:webserver],config[:uat_wb_tr],"#{n}",@elbu)}
        end

      else

      uwb = Thread.new{create_machine(app,uat_network,uat_env,config[:webserver],config[:uat_wb_tr],id,"null")}
      uwb.join

      end

      red = Thread.new{create_machine(app,uat_network,uat_env,config[:in_memory_db],config[:uat_in_db_tr],id,"null")}
      eal = Thread.new{create_machine(app,uat_network,uat_env,config[:search_engine],config[:uat_search_tr],id,"null")}
      udb.join
      red.join
      eal.join
      uwb.each {|i| i.join}

    end

    def create_prod_server(app,value_prod,prod_network,prod_env)
    # provisioning Database machine for production environment
      id = 0
      pdb = Thread.new{create_machine(app,prod_network,prod_env,config[:database],config[:prod_db_tr],id,"")}

      #------------mechanism to create instance for web and add it into load balancer PROD--------
      if @value_prod > 1

        pwb = []
        @value_prod.times do |n|
        pwb = Thread.new{create_machine(app,prod_network,prod_env,config[:webserver],config[:prod_wb_tr],"#{n}",@elbp)}
        end

      else

      pwb = Thread.new{create_machine(app,prod_network,prod_env,config[:webserver],config[:prod_wb_tr],id,"")}
      pwb.join

      end

      red = Thread.new{create_machine(app,prod_network,prod_env,config[:in_memory_db],config[:prod_in_db_tr],id,"")}
      eal = Thread.new{create_machine(app,prod_network,prod_env,config[:search_engine],config[:prod_search_tr],id,"")}
      pdb.join
      red.join
      eal.join
      pwb.each {|i| i.join}

    end

    def create_dev_server(app,uat_network,uat_env)

      id = 0
      # provisioning Database machine for development environment
      ddb = Thread.new{create_machine(app,uat_network,uat_env,config[:database],config[:dev_db_tr],id,"")}

      # mechanism to create instance for web in development environment
      dwb = Thread.new{create_machine(app,uat_network,uat_env,config[:webserver],config[:dev_wb_tr],id,"")}

      ddb.join
      dwb.join

    end

    def create_test_server(app,uat_network,uat_env)

      id = 0
      # provisioning Database machine for testing environment
      tdb = Thread.new{create_machine(app,uat_network,uat_env,config[:database],config[:tst_db_tr],id,"")}

      # mechanism to create instance for web in testing environment
      twb = Thread.new{create_machine(app,uat_network,uat_env,config[:webserver],config[:tst_wb_tr],id,"")}

      tdb.join
      twb.join

    end

  end
end
