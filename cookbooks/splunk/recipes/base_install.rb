#
# Cookbook Name::splunk
# Recipe::base_install
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

include_recipe 'splunk::system_user'
include_recipe 'splunk::download_and_install'
include_recipe 'splunk::ftr'
include_recipe 'splunk::update_admin_auth'
include_recipe 'splunk::set_servername'
