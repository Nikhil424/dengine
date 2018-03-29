#
# Cookbook Name:: splunk
# Recipe:: forwarder
#
# Copyright 2011-2012, BBY Solutions, Inc.
# Copyright 2011-2012, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
Chef::Recipe.send(:include, Splunk::Helpers)
Chef::Resource.send(:include, Splunk::Helpers)

include_recipe 'splunk::base_install'
include_recipe 'splunk::enable_forwarding'

if Chef::Config[:solo]
  Chef::Log.warn("This recipe uses search. Chef Solo does not support Search")
else
  role_name = ""
  if node['splunk']['distributed_search'] == true
    role_name = node['splunk']['indexer_role']
  else
    role_name = node['splunk']['server_role']
  end

  splunk_servers = search(:node, "role:dummi")
end


["limits"].each do |cfg|
  template "#{splunk_home}/etc/system/local/#{cfg}.conf" do
    source "forwarder/#{cfg}.conf.erb"
    owner splunk_user
    group splunk_user
    mode "0640"
    notifies :restart, "service[splunk]"
   end
end

template "Moving inputs file for role: #{node['splunk']['forwarder_role']}" do
  path "#{splunk_home}/etc/system/local/inputs.conf"
  source "forwarder/#{node['splunk']['forwarder_config_folder']}/#{node['splunk']['forwarder_role']}.inputs.conf.erb"
  owner splunk_user
  group splunk_user
  mode "0640"
  notifies :restart, "service[splunk]"
end

splunk = search(:node, 'role:*splunk*')
if splunk.empty?
  splunk_ip = '127.0.0.1'
else
  splunk_ip = splunk.first['cloud']['public_ipv4']
end

template "Moving outputs file for role: #{node['splunk']['forwarder_role']}" do
  path "#{splunk_home}/etc/system/local/outputs.conf"
  source "forwarder/#{node['splunk']['forwarder_config_folder']}/#{node['splunk']['forwarder_role']}.outputs.conf.erb"
  owner splunk_user
  group splunk_user
  mode "0640"
  variables(
  server_ip: "#{splunk_ip}"
  )
#  notifies :restart, "service[splunk]"
end

template "Moving deploymentclient file for role: #{node['splunk']['forwarder_role']}" do
  path "#{splunk_home}/etc/system/local/deploymentclient.conf"
  source "forwarder/#{node['splunk']['forwarder_config_folder']}/#{node['splunk']['forwarder_role']}.deploymentclient.conf.erb"
  owner splunk_user
  group splunk_user
  mode "0640"
  variables(
  server_ip: "#{splunk_ip}"
  )
  notifies :restart, "service[splunk]"
end

