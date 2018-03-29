#
# Cookbook Name::splunk
# Recipe::ftr
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

template "#{splunk_home}/etc/splunk-launch.conf" do
  source 'splunk-launch.conf.erb'
  mode '0640'
  owner splunk_user
  group splunk_user
  variables(
    splunk_home: splunk_home,
    splunk_db_dir: node['splunk']['db_directory'],
    splunk_user: splunk_user
  )
end

directory 'Create splunk_db directory'do
  path node['splunk']['db_directory']
  owner splunk_user
  group splunk_user
  mode '0700'
  action :create
  recursive true
  only_if { node['splunk']['db_directory'] }
end

ruby_block 'Fix Permissions on Splunk Install Directory' do
  block do
    ::FileUtils.chown_R splunk_user, splunk_user, splunk_home
  end
  only_if "test $(find #{splunk_home} \\! -user #{splunk_user} -print | wc -l) -ne 0"
end

execute 'Enable Boot Start' do
  command "#{splunk_cmd} enable boot-start "\
          "-user #{splunk_user} "\
          '--accept-license --answer-yes'
  only_if { ::File.exist? "#{splunk_home}/ftr" }
end

service 'splunk' do
  supports status: true, start: true, stop: true, restart: true
  action :start
end
