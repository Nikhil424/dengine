#
# Cookbook Name:: chef-compliance
# Recipe:: default
#
# Copyright (C) 2015 Chef Software
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Ensure that all our Omnibus-ed binaries are the ones that get used;
# much better than having to specify this on each resource!
ENV['PATH'] = "/opt/chef-compliance/bin:/opt/chef-compliance/embedded/bin:#{ENV['PATH']}"

include_recipe 'chef-compliance::_config'

# core needs information _generated_ in _dex-config, included by _dex-enable
# (oidc client id/secret)
%w(
  postgresql
  nginx
  dex
  core
).each do |service|
  if node['chef-compliance'][service]['enable']
    include_recipe "chef-compliance::_#{service}-enable"
  else
    include_recipe "chef-compliance::_#{service}-disable"
  end
end

file '/etc/chef-compliance/chef-compliance-running.json' do
  owner 'root'
  group node['chef-compliance']['user']['group']
  mode '0640'

  file_content = {
    'chef-compliance' => node['chef-compliance'].to_hash,
    'run_list' => node.run_list,
    'runit' => node['runit'].to_hash
  }

  content Chef::JSONCompat.to_json_pretty(file_content)
end

# update trigger file: its modtime is used to reset the setup's timeout
file node['chef-compliance']['setup']['triggerfile'] do
  owner 'root'
  group node['chef-compliance']['user']['group']
  mode '0640'

  action :touch
end

ruby_block 'save secrets' do
  block do
    Compliance.save_secrets
  end
end
