#dd
# Cookbook Name:: client
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "sensu::default"
include_recipe 'build-essential::default'
include_recipe "apt"

sensu_gem 'sensu-plugins-memory-checks'
sensu_gem 'sensu-plugins-cpu-checks'
sensu_gem 'sensu-plugins-disk-checks'
sensu_gem 'sensu-plugins-jenkins'
sensu_gem 'sensu-plugins-http'
sensu_gem 'sensu-plugins-mysql'
sensu_gem 'sensu-plugins-process-checks'

#file "/etc/sensu/a.txt" do
# content "#{node['ec2']['public_ipv4']}"
#end

file "/home/ubuntu/dee.pem" do
  content "dee.pem.erb"
  mode '0400'
  owner 'root'
  group 'root'
end

sensu_client "#{node.name}" do
   address "#{node['cloud']['public_ipv4']}"
  subscriptions ["base"] + ["#{node.name}"]
  keepalives true
  socket('bind' => '127.0.0.1', 'port' => 3030)
end


mast= search(:node, 'role:sensu')
if mast.empty?
  ipmast = '127.0.0.1'
else
  ipmast = mast.first['cloud']['public_ipv4']
end


template "/etc/sensu/conf.d/rabbitmq.json" do
 source 'rabbit.json.erb'
variables(
master_ip: "#{ipmast}"
 )
end



#include_recipe "sensu::rabbitmq"
#include_recipe "sensu::redis"
#include_recipe "sensu::server_service"
#include_recipe "sensu::api_service"
include_recipe "sensu::client_service"
