#
# Cookbook Name::splunk
# Recipe::update_admin_auth
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

user, pw = node['splunk']['auth'].split(':')

file "#{splunk_home}/etc/.setup_#{user}_pwd" do
  owner splunk_user
  group splunk_user
  mode '0600'
  action :nothing
end

execute 'Change default admin password' do
  command "#{splunk_home}/bin/splunk edit user #{user} "\
  "-password #{pw} "\
  '-role admin '\
  '-auth admin:changeme'
  environment 'HOME' => splunk_home
  sensitive true
  notifies :create, "file[#{splunk_home}/etc/.setup_#{user}_pwd]"
  not_if do
    ::File.exist?("#{splunk_home}/etc/.setup_#{user}_pwd") ||
      # So we don't break existing installs
      ::File.exist?('/opt/splunk_setup_passwd')
  end
end

# To clean out the old status file.
file '/opt/splunk_setup_passwd' do
  action :delete
end
