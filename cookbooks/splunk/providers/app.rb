# Copyright 2011-2016, BBY Solutions, Inc.
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

include Splunk::Helpers

def whyrun_supported?
  true
end

def load_current_resource
  @current_resource = Chef::Resource::SplunkApp.new(new_resource.name)
  conf_file = ::File.join(
    splunk_home,
    'etc',
    'apps',
    new_resource.name,
    'default',
    'app.conf')
  ::File.open(conf_file).each_line do |line|
    next unless line =~ /^version\s*=/
    current_resource.version line.split('=')[1].strip!
  end if ::File.exist? conf_file
  current_resource
end

action :install do
  unless current_resource.version == new_resource.version

    cached_package = ::File.join(
      Chef::Config[:file_cache_path],
      splunk_file(new_resource.remote_file)
    )

    cmd = "#{splunk_cmd} install app "\
    "#{cached_package} "\
    '-update true '\
    "-auth #{node['splunk']['auth']}"

    remote_file cached_package do
      source new_resource.remote_file
      checksum new_resource.checksum
      action :create_if_missing
    end

    execute 'install app' do
      command cmd
      sensitive true
      environment 'HOME' => splunk_home
      user splunk_user
      group splunk_user
      new_resource.updated_by_last_action(true)
    end
  end
end

action :remove do
  unless current_resource.version.nil?

    cmd = "#{splunk_cmd} remove app "\
      "#{new_resource.name} "\
      "-auth #{node['splunk']['auth']}"

    execute 'remove app' do
      command cmd
      sensitive true
      environment 'HOME' => splunk_home
      user splunk_user
      group splunk_user
      new_resource.updated_by_last_action(true)
    end
  end
end
