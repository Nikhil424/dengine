postgres = node['chef-compliance']['postgresql']

# Tune the ole kernel
include_recipe 'sysctl'

%w(shmmax shmall).each do |param|
  sysctl_param "kernel.#{param}" do
    value postgres[param]
  end
end

# Create our system user
user postgres['username'] do
  system true
  shell postgres['shell']
  home postgres['home']
end

directory postgres['home'] do
  owner postgres['username']
  recursive true
  mode '0700'
end

# Create our database
directory postgres['log_directory'] do
  owner node['chef-compliance']['username']
  group 'root'
  mode '0700'
  recursive true
end

enterprise_pg_cluster postgres['data_directory'] do
  encoding 'UTF8'
  notifies :restart, 'runit_service[postgresql]'
end

component_runit_service 'postgresql' do
  package 'chef-compliance'
  control ['t']
end

runit_service "postgresql" do
  action :start
end

enterprise_pg_database 'chef_compliance' do
  action :create
end

# Create our database users
enterprise_pg_user node['chef-compliance']['core']['sql_user'] do
  action :create
  password node['chef-compliance']['core']['sql_password']
  superuser false
end

enterprise_pg_user node['chef-compliance']['core']['sql_ro_user'] do
  action :create
  password node['chef-compliance']['core']['sql_ro_password']
  superuser false
end

# Create our schema
chef_compliance_pg_sqitch '/opt/chef-compliance/embedded/service/core/schema' do
  hostname  postgres['vip']
  port      postgres['port']
  username  postgres['username']
  password  postgres['db_superuser_password']
  database  'chef_compliance'
end

# Set our permissions
permissions_file = '/opt/chef-compliance/embedded/service/core/schema/permissions.sql'
template permissions_file do
  source 'permissions.sql.erb'
  action :create
  owner 'root'
  group 'root'
  mode '0644'
end

# This can run each time, since the commands in the SQL file are all
# idempotent anyway  - though we might consider only running it on notify that
# template has changed or user has been created.. .
ruby_block 'set database permissions' do
  block do
    CompliancePostgres.with_connection(node, 'chef_compliance') do |connection|
      connection.exec(File.read(permissions_file))
    end
  end
end

template '/etc/chef-compliance/.pgpass' do
  source 'pgpass.erb'
  action :create
  owner 'root'
  group 'root'
  mode '0600'
  variables(postgres)
end
