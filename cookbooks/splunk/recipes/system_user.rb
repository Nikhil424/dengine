#
# Cookbook Name::splunk
# Recipe::system_user
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
Chef::Resource::User.send(:include, Splunk::Helpers)

group node['splunk']['system_user']['username'] do
  gid node['splunk']['system_user']['uid'].to_i
  system true
end

user node['splunk']['system_user']['username'] do
  home    splunk_home
  comment node['splunk']['system_user']['comment']
  shell   node['splunk']['system_user']['shell']
  uid     node['splunk']['system_user']['uid']
  gid     node['splunk']['system_user']['username']
  system  true
end
