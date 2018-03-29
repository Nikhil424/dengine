include_recipe 'chef-compliance::_dex-postgres'

# common env vars (will be prefixed below)
env = {
  key_secrets: Compliance.dex.key_secrets.join(','),
  db_url: "postgres://#{node['chef-compliance']['dex']['sql_user']}:#{Compliance.dex.sql_password}@#{node['chef-compliance']['postgresql']['listen_address']}:#{node['chef-compliance']['postgresql']['port']}/dex?sslmode=disable",
}

%w( dex-worker dex-overlord ).each do |svc|
  user node['chef-compliance'][svc]['user'] do
    system true
    shell node['chef-compliance']['user']['shell']
    home node['chef-compliance'][svc]['home']
  end

  group node['chef-compliance'][svc]['group'] do
    members [node['chef-compliance'][svc]['user']]
  end

  directory node['chef-compliance'][svc]['log_directory'] do
    owner 'root'
    group node['chef-compliance'][svc]['group']
    mode '0750'
    recursive true
  end

  directory node['chef-compliance'][svc]['home'] do
    owner node['chef-compliance'][svc]['user']
    group node['chef-compliance'][svc]['group']
    mode '0700'
  end

  # envdir setup (dex-worker ~> DEX_WORKER_KEY_SECRETS etc)
  svc_env = env.merge(node['chef-compliance'][svc]['parameters'] || {})
  # overwrite issuer FQDN of attributes
  svc_env.values.each { |val| val.gsub!(/%%FQDN%%/, Compliance.fqdn) }
  svc_env = Hash[svc_env.map { |key, val| [svc.upcase.gsub(/-/, '_') + '_' + key.to_s.upcase, val] }]

  component_runit_service svc do
    package 'chef-compliance'
    runit_attributes({ env: svc_env })
  end
end

# Overrides the restart command from the `component_runit_service` definition
# Fixes https://github.com/chef/chef-compliance/issues/753
run_context.resource_collection.find(:execute => "restart_dex-worker_log_service").command "#{node['runit']['sv_bin']} force-restart #{node['runit']['sv_dir']}/dex-worker/log"
run_context.resource_collection.find(:execute => "restart_dex-worker_log_service").retries 1

include_recipe 'chef-compliance::_dex-config'
