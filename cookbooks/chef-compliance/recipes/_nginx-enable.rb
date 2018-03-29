include_recipe 'chef-compliance::_ssl'

[
  node['chef-compliance']['nginx']['directory'],
  node['chef-compliance']['nginx']['cache']['directory'],
  node['chef-compliance']['nginx']['log_directory'],
  node['chef-compliance']['nginx']['confd_directory'],
  node['chef-compliance']['nginx']['sites_enabled_directory'],
  node['chef-compliance']['nginx']['scripts_directory'],
  node['chef-compliance']['nginx']['addon_directory']
].each do |dir|
  directory dir do
    owner node['chef-compliance']['nginx']['user']
    group node['chef-compliance']['nginx']['group']
    mode '0750'
    recursive true
  end
end

%w(access.log error.log current).each do |logfile|
  file ::File.join(node['chef-compliance']['nginx']['log_directory'], logfile) do
    owner node['chef-compliance']['nginx']['user']
    group node['chef-compliance']['nginx']['group']
    mode '0644'
  end
end

template ::File.join(node['chef-compliance']['nginx']['directory'], 'nginx.conf') do
  source 'nginx.conf.erb'
  owner 'root'
  group 'root'
  mode '0600'
  notifies :restart, 'runit_service[nginx]'
end

template ::File.join(node['chef-compliance']['nginx']['sites_enabled_directory'], 'compliance') do
  source 'nginx-site-compliance.erb'
  owner 'root'
  group 'root'
  mode '0600'
  variables(server_names: nginx_server_names)
  notifies :restart, 'runit_service[nginx]'
  notifies :run, 'ruby_block[reset dex client]', :immediately
end

link "#{node['chef-compliance']['nginx']['directory']}/mime.types" do
  to "#{node['chef-compliance']['install_path']}/embedded/conf/mime.types"
end

component_runit_service 'nginx' do
  package 'chef-compliance'
end

# log rotation
template '/etc/chef-compliance/logrotate.d/nginx' do
  source 'logrotate.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(node['chef-compliance']['nginx'].to_hash.merge(
              'postrotate' => '/opt/chef-compliance/embedded/sbin/nginx -s reopen',
              'owner' => node['chef-compliance']['nginx']['user'],
              'group' => node['chef-compliance']['nginx']['group']
  ))
end
