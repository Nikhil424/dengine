
runit_service "dex-overlord" do
  action :start
end

# NOTE dex-overlord runs DB migrations that are necessary for dexctl to work, so
#      let's just block here.
ruby_block 'wait for dex-overlord to come up' do
  block do
    Timeout::timeout(60) do
      until system('/opt/chef-compliance/embedded/bin/curl --fail http://127.0.0.1:5557/health')
        sleep 1
      end
    end
  end
end

dexctl = '/opt/chef-compliance/embedded/service/dex/bin/dexctl'
env = {
  'DEXCTL_DB_URL' => "postgres://#{node['chef-compliance']['dex']['sql_user']}:#{Compliance.dex.sql_password}@#{node['chef-compliance']['postgresql']['listen_address']}:#{node['chef-compliance']['postgresql']['port']}/dex?sslmode=disable"
  # 'DEXCTL_DB_URL' => Compliance.dex_db_url
}

ruby_block 'reset dex client' do
  block do
    Compliance.core.oidc_client_secret = nil
  end
  action :nothing
  notifies :restart, 'runit_service[core]'
end

ruby_block 'register new dex client for core' do
  block do
    Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
    output = shell_out!("#{dexctl} new-client https://#{Compliance.fqdn}/api/callback", env: env).stdout

    client_id = client_secret = nil
    output.lines.each do |line|
      next if line.match(/^#/)

      if m = line.match(/^DEX_APP_CLIENT_ID=(.*)$/)
        client_id = m[1]
      end

      if m = line.match(/^DEX_APP_CLIENT_SECRET=(.*)$/)
        client_secret = m[1]
      end
    end

    Compliance.core.oidc_client_id = client_id
    Compliance.core.oidc_client_secret = client_secret
  end

  only_if { Compliance.core.oidc_client_secret.nil? }
end

# setup Dex connector for Chef Compliance

# read existing config from /etc/chef-compliance/dex-connectors.json
connector_config_file = "/etc/chef-compliance/dex-connectors.json"
connectors = []

if File.exist?(connector_config_file)
  begin
    connectors = JSON.parse(File.read(connector_config_file))
  rescue Exception => e
    # do nothing, we overwrite the config
  end
end

# remove existing 'compliance' connector if it exists
connectors = connectors.select { |v| v['id'] != "Compliance Server"  }

# add default Chef Compliance connector
cc_connector = {
  "type" => "compliance",
  "id" => "Compliance Server",
  "serverURL" => "https://#{Compliance.fqdn}/api/",
  "insecureSkipVerify" => !node['chef-compliance']['verify_tls']
}
connectors.push(cc_connector)

# write merged values
file connector_config_file do
  content connectors.to_json
  mode 0600
  owner 'root'
  group 'root'
  notifies :run, 'execute[configure_dex]'
end

execute "configure_dex"  do
  command "#{dexctl} set-connector-configs #{connector_config_file}"
  environment env
  notifies :restart, 'service[dex-worker]', :delayed
  notifies :restart, 'service[dex-overlord]', :delayed
end
