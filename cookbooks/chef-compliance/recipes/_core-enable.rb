runtime_path = File.join(node['chef-compliance']['core']['directory'], 'runtime')

[
  node['chef-compliance']['core']['log_directory'],
  node['chef-compliance']['core']['directory'],
  File.join(runtime_path, 'hardening-profiles')
].each do |dir|
  directory dir do
    owner 'root'
    group node['chef-compliance']['user']['group']
    mode '0750'
    recursive true
  end
end

[
  runtime_path,
  File.join(runtime_path, 'compliance-profiles')
].each do |dir|
  directory dir do
    owner node['chef-compliance']['user']['name']
    group node['chef-compliance']['user']['group']
    mode '0770'
    recursive true
  end
end

profile_path = File.join(node['chef-compliance']['install_path'],'embedded', 'service', 'compliance-profiles')

execute "clean-old-profiles" do
  command "find #{profile_path} -name inspec.yml -printf \"%h\\n\" | perl -pe \"s,#{profile_path},#{runtime_path}/compliance-profiles,\" | xargs rm -rf"
  user 'root'
  only_if { File.exist?("#{runtime_path}/compliance-profiles/README.md") }
end

execute "setup-profiles" do
  command "cp -R #{profile_path}/* #{runtime_path}/compliance-profiles"
  user 'root'
  notifies :run, 'execute[perms-profiles]', :immediately
end

execute "perms-profiles" do
  command "chown -R #{node['chef-compliance']['user']['name']} #{runtime_path}/compliance-profiles"
  user 'root'
  action :nothing
end

template '/etc/chef-compliance/server-config.json' do
  source 'server-config.json.erb'
  owner 'root'
  group node['chef-compliance']['user']['group']
  mode '0640'
  notifies :hup, 'runit_service[core]'
end

ruby_block 'configure env for core' do
  block do
    env = {
      'OIDC_CLIENT_ID' => Compliance.core.oidc_client_id,
      'OIDC_CLIENT_SECRET' => Compliance.core.oidc_client_secret,
      'HOME' => "#{node['chef-compliance']['core']['directory']}/runtime",
    }

    if !node['chef-compliance']['verify_tls']
      env['COMPLIANCE_INSECURE_TLS'] = 'ItsProbablyFine'
    end

    # set shared secret for chef-gate communication if one was generated
    unless Compliance.chef_gate.nil? || Compliance.chef_gate.shared_secret.nil?
      env['CHEF_GATE_COMPLIANCE_SECRET'] = Compliance.chef_gate.shared_secret
    end

    core_runit = run_context.resource_collection.find(:runit_service => 'core')
    core_runit.env env
  end
end

component_runit_service 'core' do
  package 'chef-compliance'
end
