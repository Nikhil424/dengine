#
# Cookbook Name::splunk
# Recipe::set_servername
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
Chef::Resource.send(:include, Splunk::Helpers)

execute 'Set Splunk Servername' do
  command "#{splunk_home}/bin/splunk set servername #{node['splunk']['hostname']} -auth #{node['splunk']['auth']}"
  environment 'HOME' => splunk_home
  sensitive true
  not_if "#{splunk_home}/bin/splunk show servername -auth #{node['splunk']['auth']} | grep #{node['splunk']['hostname']}", environment: { 'HOME' => splunk_home }
  notifies :restart, 'service[splunk]', :delayed
end
