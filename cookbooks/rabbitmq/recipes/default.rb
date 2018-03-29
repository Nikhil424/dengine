# frozen_string_literal: true
#
# Cookbook Name:: rabbitmq
# Recipe:: default
#
# Copyright 2009, Benjamin Black
# Copyright 2009-2013, Chef Software, Inc.
# Copyright 2012, Kevin Nuckolls <kevin.nuckolls@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
class Chef::Resource
  include Opscode::RabbitMQ # rubocop:enable all
end

include_recipe 'erlang'

## Install the package
case node['platform_family']
when 'debian'

  template '/etc/apt/apt.conf.d/90forceyes' do
    source '90forceyes.erb'
    owner 'root'
    group 'root'
    mode '0644'
  end

  # logrotate is a package dependency of rabbitmq-server
  package 'logrotate'

  # socat is a package dependency of rabbitmq-server
  package 'socat'

  # => Prevent Debian systems from automatically starting RabbitMQ after dpkg install
  dpkg_autostart node['rabbitmq']['service_name'] do
    allow false
  end

  if node['platform_version'].to_i < 8 && !node['rabbitmq']['use_distro_version']
    Chef::Log.warn 'Debian 7 is too old to use the recent .deb RabbitMQ packages. Falling back to distro package!'
    node.normal['rabbitmq']['use_distro_version'] = true
  end

  if node['rabbitmq']['use_distro_version']
    package 'rabbitmq-server' do
      action :install
      version node['rabbitmq']['version'] if node['rabbitmq']['pin_distro_version']
    end
  else
    # we need to download the package
    deb_package = "#{node['rabbitmq']['deb_package_url']}#{node['rabbitmq']['deb_package']}"
    remote_file "#{Chef::Config[:file_cache_path]}/#{node['rabbitmq']['deb_package']}" do
      source deb_package
      action :create_if_missing
    end
    package 'rabbitmq-server' do
      provider Chef::Provider::Package::Dpkg
      source ::File.join(Chef::Config[:file_cache_path], node['rabbitmq']['deb_package'])
      action :upgrade
    end
  end

  # Configure job control
  if node['rabbitmq']['job_control'] == 'upstart' && node['rabbitmq']['manage_service']
    # We start with stock init.d, remove it if we're not using init.d, otherwise leave it alone
    service node['rabbitmq']['service_name'] do
      action [:stop]
      only_if { File.exist?('/etc/init.d/rabbitmq-server') }
    end

    execute 'remove rabbitmq init.d command' do
      command 'update-rc.d -f rabbitmq-server remove'
    end

    file '/etc/init.d/rabbitmq-server' do
      action :delete
    end

    template "/etc/init/#{node['rabbitmq']['service_name']}.conf" do
      source 'rabbitmq.upstart.conf.erb'
      owner 'root'
      group 'root'
      mode 0644
      variables(:max_file_descriptors => node['rabbitmq']['max_file_descriptors'])
    end
  end

when 'rhel', 'fedora'

  # logrotate is a package dependency of rabbitmq-server
  package 'logrotate'

  # socat is a package dependency of rabbitmq-server
  package 'socat'

  # This is needed since Erlang Solutions' packages provide "esl-erlang"; this package just requires "esl-erlang" and provides "erlang".
  if node['erlang']['install_method'] == 'esl'
    remote_file "#{Chef::Config[:file_cache_path]}/esl-erlang-compat.rpm" do
      source "#{node['rabbitmq']['esl-erlang_package_url']}#{node['rabbitmq']['esl-erlang_package']}"
    end
    rpm_package "#{Chef::Config[:file_cache_path]}/esl-erlang-compat.rpm"
  end

  if node['rabbitmq']['use_distro_version']
    package 'rabbitmq-server' do
      action :install
      version node['rabbitmq']['version'] if node['rabbitmq']['pin_distro_version']
    end
  else
    # We need to download the rpm
    rpm_package = "#{node['rabbitmq']['rpm_package_url']}#{node['rabbitmq']['rpm_package']}"

    remote_file "#{Chef::Config[:file_cache_path]}/#{node['rabbitmq']['rpm_package']}" do
      source rpm_package
      action :create_if_missing
    end
    rpm_package "#{Chef::Config[:file_cache_path]}/#{node['rabbitmq']['rpm_package']}"
  end

when 'suse'

  # logrotate is a package dependency of rabbitmq-server
  package 'logrotate'

  # socat is a package dependency of rabbitmq-server
  package 'socat'

  # rabbitmq-server-plugins needs to be first so they both get installed
  # from the right repository. Otherwise, zypper will stop and ask for a
  # vendor change.
  package 'rabbitmq-server-plugins' do
    action :install
    version node['rabbitmq']['version']
  end
  package 'rabbitmq-server' do
    action :install
    version node['rabbitmq']['version'] if node['rabbitmq']['pin_distro_version']
  end

when 'smartos'
  package 'rabbitmq' do
    action :install
    version node['rabbitmq']['version'] if node['rabbitmq']['pin_distro_version']
  end

  service 'epmd' do
    action :start
  end

end

if node['rabbitmq']['logdir']
  directory node['rabbitmq']['logdir'] do
    owner 'rabbitmq'
    group 'rabbitmq'
    mode '775'
    recursive true
  end
end

directory node['rabbitmq']['mnesiadir'] do
  owner 'rabbitmq'
  group 'rabbitmq'
  mode '775'
  recursive true
end

template "#{node['rabbitmq']['config_root']}/rabbitmq-env.conf" do
  source 'rabbitmq-env.conf.erb'
  owner 'root'
  group 'root'
  mode 00644
  notifies :restart, "service[#{node['rabbitmq']['service_name']}]"
end

template "#{node['rabbitmq']['config']}.config" do
  sensitive true if Gem::Version.new(Chef::VERSION.to_s) >= Gem::Version.new('11.14.2')
  source 'rabbitmq.config.erb'
  cookbook node['rabbitmq']['config_template_cookbook']
  owner 'root'
  group 'root'
  mode 00644
  variables(
    :kernel => format_kernel_parameters,
    :ssl_versions => (format_ssl_versions if node['rabbitmq']['ssl_versions']),
    :ssl_ciphers => (format_ssl_ciphers if node['rabbitmq']['ssl_ciphers'])
  )
  notifies :restart, "service[#{node['rabbitmq']['service_name']}]"
end

template "/etc/default/#{node['rabbitmq']['service_name']}" do
  source 'default.rabbitmq-server.erb'
  owner 'root'
  group 'root'
  mode 00644
  notifies :restart, "service[#{node['rabbitmq']['service_name']}]"
end

existing_erlang_key = if File.exist?(node['rabbitmq']['erlang_cookie_path']) && File.readable?((node['rabbitmq']['erlang_cookie_path']))
                        File.read(node['rabbitmq']['erlang_cookie_path']).strip
                      else
                        ''
                      end

if node['rabbitmq']['clustering']['enable'] && (node['rabbitmq']['erlang_cookie'] != existing_erlang_key)
  log "stop #{node['rabbitmq']['service_name']} to change erlang cookie" do
    notifies :stop, "service[#{node['rabbitmq']['service_name']}]", :immediately
  end

  template node['rabbitmq']['erlang_cookie_path'] do
    source 'doterlang.cookie.erb'
    owner 'rabbitmq'
    group 'rabbitmq'
    mode 00400
    notifies :start, "service[#{node['rabbitmq']['service_name']}]", :immediately
    notifies :run, 'execute[reset-node]', :immediately
  end

  # Need to reset for clustering #
  execute 'reset-node' do
    command 'rabbitmqctl stop_app && rabbitmqctl reset && rabbitmqctl start_app'
    action :nothing
  end
end

if node['rabbitmq']['manage_service']
  service node['rabbitmq']['service_name'] do
    action [:enable, :start]
    supports :status => true, :restart => true
    provider Chef::Provider::Service::Upstart if node['rabbitmq']['job_control'] == 'upstart'
    provider Chef::Provider::Service::Init if node['rabbitmq']['job_control'] == 'init'
  end
else
  service node['rabbitmq']['service_name'] do
    action :nothing
  end
end
