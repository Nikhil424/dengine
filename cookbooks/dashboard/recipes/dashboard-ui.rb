include_recipe 'webserver::default'
include_recipe 'php::default'

apt_package 'libapache2-mod-php5' do
  action :install
end
