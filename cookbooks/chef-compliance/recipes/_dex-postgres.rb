enterprise_pg_database 'dex' do
  action :create
end

enterprise_pg_user node['chef-compliance']['dex']['sql_user'] do
  action :create
  password node['chef-compliance']['dex']['sql_password']
  superuser false
end

enterprise_pg_user node['chef-compliance']['dex']['sql_ro_user'] do
  action :create
  password node['chef-compliance']['dex']['sql_ro_password']
  superuser false
end

# Set dex' permissions
# XXX these could probably be tighter
permissions_file = '/opt/chef-compliance/embedded/service/dex/schema/permissions.sql'

directory ::Pathname.new(permissions_file).dirname.to_s do
  action :create
  owner 'root'
  group 'root'
  mode '0600'
end

template permissions_file do
  source 'dex-permissions.sql.erb'
  action :create
  owner 'root'
  group 'root'
  mode '0644'
end

# This can run each time, since the commands in the SQL file are all
# idempotent anyway  - though we might consider only running it on notify that
# template has changed or user has been created.. .
ruby_block 'set dex database permissions' do
  block do
    CompliancePostgres.with_connection(node, 'dex') do |connection|
      connection.exec(File.read(permissions_file))
    end
  end
end
