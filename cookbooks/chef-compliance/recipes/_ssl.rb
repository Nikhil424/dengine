[
  node['chef-compliance']['ssl']['directory'],
  node['chef-compliance']['ssl']['ca_directory']
].each do |dir|
  directory dir do
    owner 'root'
    group node['chef-compliance']['user']['group']
    mode '0750'
  end
end

ssl_dhparam = File.join(node['chef-compliance']['ssl']['ca_directory'], 'dhparams.pem')

openssl_dhparam ssl_dhparam do
  key_length 2048
  generator 2
  owner 'root'
  group 'root'
  mode '0644'
end

node.default['chef-compliance']['ssl']['ssl_dhparam'] ||= ssl_dhparam

if node['chef-compliance']['ssl']['certificate']
  link "#{node['chef-compliance']['ssl']['directory']}/cacert.pem" do
    to "#{node['chef-compliance']['install_directory']}/embedded/ssl/certs/cacert.pem"
  end
else
  ssl_keyfile = File.join(node['chef-compliance']['ssl']['ca_directory'], "#{node['chef-compliance']['fqdn']}.key")
  ssl_crtfile = File.join(node['chef-compliance']['ssl']['ca_directory'], "#{node['chef-compliance']['fqdn']}.crt")

  openssl_x509 ssl_crtfile do
    common_name node['chef-compliance']['fqdn']
    org node['chef-compliance']['ssl']['company_name']
    org_unit node['chef-compliance']['ssl']['organizational_unit_name']
    country node['chef-compliance']['ssl']['country_name']
    key_length 2048
    expire 3650
    owner 'root'
    group 'root'
    mode '0644'
  end

  node.default['chef-compliance']['ssl']['certificate'] ||= ssl_crtfile
  node.default['chef-compliance']['ssl']['certificate_key'] ||= ssl_keyfile

  link "#{node['chef-compliance']['ssl']['directory']}/cacert.pem" do
    to ssl_crtfile
  end
end
