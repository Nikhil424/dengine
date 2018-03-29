current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                'chefcoe'
client_key               '/var/lib/jenkins/chef-repo/.chef/chefcoe.pem'
validation_client_name   'chef-validator'
validation_key           '/var/lib/jenkins/chef-repo/.chef/masterchefcoe-validator.pem'
chef_server_url          'https://ec2-54-213-74-217.us-west-2.compute.amazonaws.com/organizations/chef'
cookbook_path            ["/var/lib/jenkins/chef-repo/cookbooks"]
syntax_check_cache_path  '/var/lib/jenkins/chef-repo/syntax_cache'
ssl_verify_mode    :verify_none

knife[:editor]   = "vi"
knife[:ssh_user] = 'ubuntu'
# The data required by knife to authenticate with AWS console/account
#knife[:aws_credential_file] = '/root/chef-repo/.chef/credentials/aws_credential_file'
knife[:aws_access_key_id]     = 'AKIAIK4ZFHT7ZUEJU5TQ'
knife[:aws_secret_access_key] = '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'
knife[:identity_file]         = '/var/lib/jenkins/chef-repo/.chef/new-iac-coe.pem'
knife[:ssh_key_name]          = 'new-iac-coe'
knife[:winrm_port]            = '5985'
knife[:region]                = 'us-west-2'
knife[:image]                 = 'ami-8a9d5dea'

# The data required by knife to authenticate with AZURE console/account
knife[:azure_publish_settings_file] = '/root/chef-repo/.chef/credentials/Trial-2-9-2017-credentials.publishsettings'
knife[:azure_source_image] = '0b11de9248dd4d87b18621318e037d37__RightImage-Ubuntu-14.04-x64-v14.2.1'
#knife[:identity_file] = '/root/chef-repo/.chef/myazure_rsa'
#knife[:azure_subscription_id] = 'a73bcbae-fa0c-49a2-8f04-27e8126898ba'
#knife[:azure_mgmt_cert] = '/root/chef-repo/.chef/management-certificate.pem'
#knife[:azure_api_host_name] = 'https://management.core.windows.net'
