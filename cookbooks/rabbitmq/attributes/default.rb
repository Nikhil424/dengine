# frozen_string_literal: true
# Latest RabbitMQ.com version to install
default['rabbitmq']['version'] = '3.6.8'
# The distro versions may be more stable and have back-ported patches
default['rabbitmq']['use_distro_version'] = false
# Allow the distro version to be optionally pinned like the rabbitmq.com version
default['rabbitmq']['pin_distro_version'] = false

# provide options to override download urls and package names
default['rabbitmq']['deb_package'] = "rabbitmq-server_#{node['rabbitmq']['version']}-1_all.deb"
default['rabbitmq']['deb_package_url'] = "https://www.rabbitmq.com/releases/rabbitmq-server/v#{node['rabbitmq']['version']}/"

case node['platform_family']
when 'rhel', 'fedora'
  default['rabbitmq']['rpm_package'] = if node['platform_version'].to_i > 6
                                         "rabbitmq-server-#{node['rabbitmq']['version']}-1.el7.noarch.rpm"
                                       else
                                         "rabbitmq-server-#{node['rabbitmq']['version']}-1.el6.noarch.rpm"
                                       end
when 'suse'
  default['rabbitmq']['rpm_package'] = "rabbitmq-server-#{node['rabbitmq']['version']}-1.suse.noarch.rpm"
end

default['rabbitmq']['rpm_package_url'] = "https://www.rabbitmq.com/releases/rabbitmq-server/v#{node['rabbitmq']['version']}/"

# RabbitMQ 3.6.8+ non-distro versions requires a modern Erlang which is neither available in
# older distros via packages nor EPEL. rhel < 7, debian < 8
#
if !node['rabbitmq']['use_distro_version'] &&
   (node['platform'] == 'debian' && node['platform_version'].to_i < 8 ||
    node['platform_family'] == 'rhel' && node['platform_version'].to_i < 7)
  default['erlang']['install_method'] = 'esl'
end

default['rabbitmq']['esl-erlang_package'] = 'esl-erlang-compat-R16B03-1.noarch.rpm?raw=true'
default['rabbitmq']['esl-erlang_package_url'] = 'https://github.com/jasonmcintosh/esl-erlang-compat/blob/master/rpmbuild/RPMS/noarch/'

# being nil, the rabbitmq defaults will be used
default['rabbitmq']['nodename'] = nil
default['rabbitmq']['address'] = nil
default['rabbitmq']['port'] = nil
default['rabbitmq']['config'] = nil
default['rabbitmq']['logdir'] = nil
default['rabbitmq']['server_additional_erl_args'] = nil
default['rabbitmq']['ctl_erl_args'] = nil
default['rabbitmq']['mnesiadir'] = '/var/lib/rabbitmq/mnesia'
default['rabbitmq']['service_name'] = 'rabbitmq-server'
default['rabbitmq']['manage_service'] = true

# config file location
# http://www.rabbitmq.com/configure.html#define-environment-variables
# "The .config extension is automatically appended by the Erlang runtime."
default['rabbitmq']['config_root'] = '/etc/rabbitmq'
default['rabbitmq']['config'] = "#{node['rabbitmq']['config_root']}/rabbitmq"
default['rabbitmq']['erlang_cookie_path'] = '/var/lib/rabbitmq/.erlang.cookie'
default['rabbitmq']['erlang_cookie'] = 'AnyAlphaNumericStringWillDo'
# override this if you wish to provide `rabbitmq.config.erb` in your own wrapper cookbook
default['rabbitmq']['config_template_cookbook'] = 'rabbitmq'

# rabbitmq.config defaults
default['rabbitmq']['default_user'] = 'guest'
default['rabbitmq']['default_pass'] = 'guest'

# loopback_users
# List of users which are only permitted to connect to the broker via a loopback interface (i.e. localhost).
# If you wish to allow the default guest user to connect remotely, you need to change this to [].
default['rabbitmq']['loopback_users'] = nil

# Erlang kernel application options
# See http://www.erlang.org/doc/man/kernel_app.html
default['rabbitmq']['kernel']['inet_dist_listen_min'] = nil
default['rabbitmq']['kernel']['inet_dist_listen_max'] = nil

# Tell Erlang what IP to bind to
default['rabbitmq']['kernel']['inet_dist_use_interface'] = nil

# clustering
default['rabbitmq']['clustering']['enable'] = false
default['rabbitmq']['clustering']['cluster_partition_handling'] = 'ignore'

default['rabbitmq']['clustering']['use_auto_clustering'] = false
default['rabbitmq']['clustering']['cluster_name'] = nil
default['rabbitmq']['clustering']['cluster_nodes'] = []

# Manual clustering
# - Node type : master | slave
default['rabbitmq']['clustering']['node_type'] = 'master'
# - Master node name : ex) rabbit@rabbit1
default['rabbitmq']['clustering']['master_node_name'] = 'rabbit@rabbit1'
# - Cluster node type : disc | ram
default['rabbitmq']['clustering']['cluster_node_type'] = 'disc'

# log levels
default['rabbitmq']['log_levels'] = { 'connection' => 'info' }

# resource usage
default['rabbitmq']['disk_free_limit_relative'] = nil
default['rabbitmq']['disk_free_limit'] = nil
default['rabbitmq']['vm_memory_high_watermark'] = nil
default['rabbitmq']['max_file_descriptors'] = 1024
default['rabbitmq']['open_file_limit'] = nil

# job control
default['rabbitmq']['job_control'] = 'initd'

# ssl
default['rabbitmq']['ssl'] = false
default['rabbitmq']['ssl_port'] = 5671
default['rabbitmq']['ssl_cacert'] = '/path/to/cacert.pem'
default['rabbitmq']['ssl_cert'] = '/path/to/cert.pem'
default['rabbitmq']['ssl_key'] = '/path/to/key.pem'
default['rabbitmq']['ssl_verify'] = 'verify_none'
default['rabbitmq']['ssl_fail_if_no_peer_cert'] = false
# Specify SSL versions
# Example:
#   ['tlsv1.2', 'tlsv1.1']
default['rabbitmq']['ssl_versions'] = nil
# Specify SSL ciphers
# Examples:
# ['{ecdhe_ecdsa,aes_128_cbc,sha256}', '{ecdhe_ecdsa,aes_256_cbc,sha}']
# or in OpenSSL format:
# ['"ECDHE-ECDSA-AES128-SHA256"', '"ECDHE-ECDSA-AES256-SHA"']
default['rabbitmq']['ssl_ciphers'] = nil
default['rabbitmq']['web_console_ssl'] = false
default['rabbitmq']['web_console_ssl_port'] = 15_671

# Change non SSL web console listen port
default['rabbitmq']['web_console_port'] = 15672

# tcp listen options
default['rabbitmq']['tcp_listen'] = true
default['rabbitmq']['tcp_listen_packet'] = 'raw'
default['rabbitmq']['tcp_listen_reuseaddr'] = true
default['rabbitmq']['tcp_listen_backlog'] = 128
default['rabbitmq']['tcp_listen_nodelay'] = true
default['rabbitmq']['tcp_listen_exit_on_close'] = false
default['rabbitmq']['tcp_listen_keepalive'] = false
default['rabbitmq']['tcp_listen_linger'] = true
default['rabbitmq']['tcp_listen_linger_timeout'] = 0

# virtualhosts
default['rabbitmq']['virtualhosts'] = []
default['rabbitmq']['disabled_virtualhosts'] = []

# users
default['rabbitmq']['enabled_users'] =
  [{ :name => 'guest', :password => 'guest', :rights =>
    [{ :vhost => nil, :conf => '.*', :write => '.*', :read => '.*' }]
  }]
default['rabbitmq']['disabled_users'] = []

# plugins
default['rabbitmq']['enabled_plugins'] = []
default['rabbitmq']['disabled_plugins'] = []
default['rabbitmq']['community_plugins'] = {}

# platform specific settings
case node['platform_family']
when 'smartos'
  default['rabbitmq']['service_name'] = 'rabbitmq'
  default['rabbitmq']['config_root'] = '/opt/local/etc/rabbitmq'
  default['rabbitmq']['config'] = "#{node['rabbitmq']['config_root']}/rabbitmq"
  default['rabbitmq']['erlang_cookie_path'] = '/var/db/rabbitmq/.erlang.cookie'
when 'debian'
  default['apt']['confd']['assume_yes'] = false
  default['apt']['confd']['force-yes'] = false
end

# heartbeat
default['rabbitmq']['heartbeat'] = 60

# per default all policies and disabled policies are empty but need to be
# defined
default['rabbitmq']['policies'] = {}
default['rabbitmq']['disabled_policies'] = []

# Example HA policies
# default['rabbitmq']['policies']['ha-all']['pattern'] = '^(?!amq\\.).*'
# default['rabbitmq']['policies']['ha-all']['params'] = { 'ha-mode' => 'all' }
# default['rabbitmq']['policies']['ha-all']['priority'] = 0
#
# default['rabbitmq']['policies']['ha-two']['pattern'] = '^two.'
# default['rabbitmq']['policies']['ha-two']['params'] = { 'ha-mode' => 'exactly', 'ha-params' => 2 }
# default['rabbitmq']['policies']['ha-two']['priority'] = 1

# conf
default['rabbitmq']['conf'] = {}
default['rabbitmq']['additional_rabbit_configs'] = {}
