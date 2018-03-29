current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                'chefcoe'
client_key               '/var/lib/jenkins/chef-repo/.chef/chefcoe.pem'
validation_client_name   'chef-validator'
validation_key           '/var/lib/jenkins/chef-repo/.chef/masterchefcoe-validator.pem'
chef_server_url          'https://X.X.X.X/organizations/chef'
cookbook_path            ["/var/lib/jenkins/chef-repo/cookbooks"]
syntax_check_cache_path  '/var/lib/jenkins/syntax_cache'
ssl_verify_mode    :verify_none

knife[:editor]   = "vi"
#knife[:supermarket_site] = "https://ec2-34-209-251-74.us-west-2.compute.amazonaws.com"
knife[:ssh_user] = 'ubuntu'
# The data required by knife to authenticate with AWS console/account
#knife[:aws_credential_file] = '/root/chef-repo/.chef/credentials/aws_credential_file'
knife[:aws_access_key_id]     = 'XXXXXXXXXXXXXXXXXXXXXXXXXXX'
knife[:aws_secret_access_key] = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
knife[:identity_file]         = '/var/lib/jenkins/chef-repo/.chef/new-iac-coe.pem'
knife[:ssh_key_name]          = 'chef-coe-ind'
knife[:ssh_user]              = 'ubuntu'
knife[:winrm_port]            = '5985'
knife[:region]                = 'ap-south-1'
knife[:image]                 = 'ami-46eea129'
knife[:security_group_ids]    = 'chef'
knife[:ssh_port]              = 22

# The data required by knife to authenticate with AZURE console/account
#knife[:azure_publish_settings_file] = '/root/chef-repo/.chef/credentials/Trial-2-9-2017-credentials.publishsettings'
#knife[:azure_source_image] = '0b11de9248dd4d87b18621318e037d37__RightImage-Ubuntu-14.04-x64-v14.2.1'
#knife[:identity_file] = '/root/chef-repo/.chef/myazure_rsa'
#knife[:azure_subscription_id] = 'a73bcbae-fa0c-49a2-8f04-27e8126898ba'
#knife[:azure_mgmt_cert] = '/root/chef-repo/.chef/management-certificate.pem'
#knife[:azure_api_host_name] = 'https://management.core.windows.net'

#------------------------azure  and openstack credentials--------------------------

knife[:azure_tenant_id] = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
knife[:azure_subscription_id] = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
knife[:azure_client_id] = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
knife[:azure_client_secret] = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
knife[:azure_resource_group_name] = "Dengine"
knife[:azure_service_location] = "CentralIndia"

knife[:azure_image] = "ubuntu"

#---------------------openstack details----------------------------------
knife[:openstack_auth_url] = "https://sandbox.platform9.net/keystone/v2.0/tokens"
knife[:openstack_username] = "XXXXXXXXXXXXXX.@gmail.com"
knife[:openstack_password] = "42soorya24"
knife[:openstack_tenant] = "tenant-xxxxxxxxxxxxxxxtgmailcom"
knife[:openstack_region] = "US-West-KVM-01"

#knife[:ops_key]               = 'test_key'
knife[:network_ids]           = '957b9d6'
knife[:ops_image]             = 'bbdd7252-6298-d7ba-60ed-2d7454356ae1'

#-----------------------Google Cloud details-----------------------
knife[:gce_project] = "xxxxxxxxxxxxxxxx"
knife[:gce_zone] = "us-central1-c"

knife[:gce_image] = "ubuntu-14-04"
#knife[:GOOGLE_APPLICATION_CREDENTIALS] = "/root/chef-repo/.chef/Project-ce1019e73f90.json"

#-------------------------------------------------------------------
#knife[:gateway_key] = "/var/lib/jenkins/chef-repo/.chef/google_key.ppk"
knife[:public_key]  = "/var/lib/jenkins/chef-repo/.chef/google_key"
