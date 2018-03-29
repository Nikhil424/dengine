etc_path = '/etc/chef-compliance'
directory etc_path do
  owner 'root'
  group 'root'
  mode '0775'
  action :create
end

config = "#{etc_path}/chef-compliance.rb"
Compliance.from_file(config) if File.exist?(config)

node.consume_attributes('chef-compliance' => Compliance.generate_config(node['fqdn']))
node.consume_attributes('nginx' => node['chef-compliance']['nginx'])

include_recipe 'enterprise::runit'

directory '/var/opt/chef-compliance' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

directory '/etc/chef-compliance/logrotate.d' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

directory '/var/log/chef-compliance' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

user node['chef-compliance']['user']['name'] do
  system true
  shell node['chef-compliance']['user']['shell']
  home node['chef-compliance']['user']['home']
end

group node['chef-compliance']['user']['group'] do
  append true
  members [node['chef-compliance']['user']['name']]
  system true
end
