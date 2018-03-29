# Name of the cookbook (referenced in forwarder.rb)
default['splunk']['cookbook_name']             = "splunk"

# install type (server/forwarder)
default['splunk']['install_type'] = 'server'

default['splunk']['hostname'] = "#{node['ec2'] ? node['ec2']['instance_id'] : node['fqdn']}-splunk"

# Run Splunk As
default['splunk']['run_as_root'] = true
default['splunk']['system_user']['username'] = 'splunk'
default['splunk']['system_user']['comment'] = 'Splunk Server'
default['splunk']['system_user']['shell'] = '/bin/bash'
default['splunk']['system_user']['uid'] = 396

#directories  (Only set if deviating from default splunk install)
default['splunk']['home']                      = nil
default['splunk']['server_home']               = '/opt/splunk'
default['splunk']['db_directory']              = nil

#Change the default admin password (Username::Password)
default['splunk']['auth']                      = "admin:SomePassword123"

# Forwarding and receiving
default['splunk']['forwarding']['port']                          = "9997"
default['splunk']['forwarding']['compressed']                    = true
# If SSL is enabled, but no cert configurations are populated,
# then splunk will use self-signed certs.
default['splunk']['forwarding']['ssl']['enable']                 = false
# To use your own certs, update the below settings
default['splunk']['forwarding']['ssl']['cacert']                 = '$SPLUNK_HOME/etc/auth/cacert.pem'
default['splunk']['forwarding']['ssl']['servercert']             = '$SPLUNK_HOME/etc/auth/server.pem'
default['splunk']['forwarding']['ssl']['password']               = 'password'
default['splunk']['forwarding']['ssl']['requireClientCert']      = false
default['splunk']['forwarding']['ssl']['sslVerifyServerCert']    = false

default['splunk']['forwarding']['indexers'] = nil

#web config
default['splunk']['web_server_port']           = "80" # Change to 443/other if you're doing ssl
default['splunk']['root_endpoint']             = "/" # Web Endpoint
default['splunk']['browser_timeout']           = "0"
default['splunk']['minify_js']                 = "true"
default['splunk']['minify_css']                = "true"

default['splunk']['use_ssl']                   = false
default['splunk']['ssl_crt']                   = "ssl.crt"
default['splunk']['ssl_key']                   = "ssl.key"

# Dashboards to deploy
default['splunk']['deploy_dashboards']         = true
default['splunk']['dashboards_to_deploy']      = ["apache_http","useragents"]


default['splunk']['server_config_folder']      = "prodlike"

# Static Server Configs (Configs that match regardless of environment -Dev,QA,PL,Prod,Etc)
default['splunk']['static_server_configs']     = ["web","transforms","limits","indexes"]

# Dynamic Server Configs (Configs that change per environment)
default['splunk']['dynamic_server_configs']    = ["props"]

# Set the role of your splunk server/dedicated search head
default['splunk']['server_role']               = "splunk-server"
# Needed for distributed search.  This is assigned to the indexers.
default['splunk']['indexer_role']              = "splunk-indexer"

# limits.conf
default['splunk']['max_searches_per_cpu']      = 4
