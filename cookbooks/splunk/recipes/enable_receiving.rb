#
# Cookbook Name::splunk
# Recipe::enable_receiving
#
# Copyright 2011-2016, BBY Solutions, Inc.
# Copyright 2011-2016, Opscode, Inc.
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

conf_file = ::File.join(
  splunk_home,
  'etc',
  'system',
  'local',
  'inputs.conf')

ruby_block 'capture hashed password' do
  block do
    password = ''

    ::File.open(conf_file).each_line do |line|
      next unless line =~ /^password\s*=/
      password = line[/^password = (.*$)/, 1]
    end if ::File.exist? conf_file

    if password =~ /^\$1\$/ &&
       password != node['splunk']['forwarding']['ssl']['password']
      node.normal['splunk']['forwarding']['ssl']['password'] = password
      node.save
    end
  end
end if node['splunk']['forwarding']['ssl']['enable']

template conf_file do
  source 'inputs.conf.erb'
  owner splunk_user
  group splunk_user
  variables(
    hostname: node['splunk']['hostname'],
    compressed: node['splunk']['forwarding']['compressed'],
    port: node['splunk']['forwarding']['port'],
    ssl: node['splunk']['forwarding']['ssl']
  )
  mode '0644'
  notifies :restart, 'service[splunk]', :delayed
end
