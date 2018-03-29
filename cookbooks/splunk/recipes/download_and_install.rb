#
# Cookbook Name::splunk
# Recipe::download_and_install
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

cache_dir      = Chef::Config[:file_cache_path]
source         = node['splunk']['remote_url'] || splunk_download_url
package_file   = splunk_file(source)
cached_package = ::File.join(cache_dir, package_file)

remote_file cached_package do
  source source
  action :create_if_missing
end

package 'splunk' do
  source cached_package
  version node['splunk']['version']
  provider case node['platform_family']
           when 'rhel'   then Chef::Provider::Package::Rpm
           when 'debian' then Chef::Provider::Package::Dpkg
           end
end
