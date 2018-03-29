# Use different shells based on platform. CIS profiles look for these in tests
shell = node['platform'] == 'ubuntu' ? '/usr/sbin/nologin' : '/sbin/nologin'

# Chef Compliance
default['chef-compliance']['user']['name'] = 'chef-compliance'
default['chef-compliance']['user']['shell'] = shell
default['chef-compliance']['user']['home'] = '/opt/chef-compliance/embedded'
default['chef-compliance']['user']['groups'] = [] # This does not do anything, here for legacy config files
default['chef-compliance']['user']['group'] = 'chef-compliance'
default['chef-compliance']['log_directory'] = '/var/log/chef-compliance'
default['chef-compliance']['setup']['registration']['required'] = false
default['chef-compliance']['setup']['triggerfile'] = '/var/opt/chef-compliance/core/setup-trigger'
default['chef-compliance']['verify_tls'] = false

# Enterprise
default['enterprise']['name'] = 'chef-compliance'
default['chef-compliance']['install_path'] = '/opt/chef-compliance'
default['chef-compliance']['sysvinit_id'] = 'COMP'

# Nginx
default['chef-compliance']['nginx']['enable'] = true
default['chef-compliance']['nginx']['directory'] = '/var/opt/chef-compliance/nginx/etc'
default['chef-compliance']['nginx']['confd_directory'] = '/var/opt/chef-compliance/nginx/etc/conf.d'
default['chef-compliance']['nginx']['sites_enabled_directory'] = '/var/opt/chef-compliance/nginx/etc/sites-enabled'
default['chef-compliance']['nginx']['scripts_directory'] = '/var/opt/chef-compliance/nginx/etc/scripts'
default['chef-compliance']['nginx']['addon_directory'] = '/var/opt/chef-compliance/nginx/etc/addon.d'
default['chef-compliance']['nginx']['log_directory'] = '/var/log/chef-compliance/nginx'
default['chef-compliance']['nginx']['force_ssl'] = true
default['chef-compliance']['nginx']['non_ssl_port'] = 80
default['chef-compliance']['nginx']['ssl_port'] = 443
default['chef-compliance']['nginx']['log_rotation']['file_maxbytes'] = 104_857_600
default['chef-compliance']['nginx']['log_rotation']['num_to_keep'] = 10
default['chef-compliance']['nginx']['log_formats'] = {}
default['chef-compliance']['nginx']['redirect_to_canonical'] = true
default['chef-compliance']['nginx']['cache']['enable'] = false
default['chef-compliance']['nginx']['cache']['directory'] = '/var/opt/chef-compliance/nginx/cache'
default['chef-compliance']['nginx']['dir'] = node['chef-compliance']['nginx']['directory']
default['chef-compliance']['nginx']['log_dir'] = node['chef-compliance']['nginx']['log_directory']
default['chef-compliance']['nginx']['user'] = node['chef-compliance']['user']['name']
default['chef-compliance']['nginx']['group'] = node['chef-compliance']['user']['group']
default['chef-compliance']['nginx']['pid'] = "#{node['chef-compliance']['nginx']['dir']}/nginx.pid"
default['chef-compliance']['nginx']['daemon_disable'] = true
default['chef-compliance']['nginx']['gzip'] = 'on'
default['chef-compliance']['nginx']['gzip_static'] = 'off'
default['chef-compliance']['nginx']['gzip_http_version'] = '1.0'
default['chef-compliance']['nginx']['gzip_comp_level'] = '2'
default['chef-compliance']['nginx']['gzip_proxied'] = 'any'
default['chef-compliance']['nginx']['gzip_vary'] = 'off'
default['chef-compliance']['nginx']['gzip_buffers'] = nil
default['chef-compliance']['nginx']['gzip_types'] = %w(
  text/plain
  text/css
  application/x-javascript
  text/xml
  application/xml
  application/rss+xml
  application/atom+xml
  text/javascript
  application/javascript
  application/json
)
default['chef-compliance']['nginx']['gzip_min_length'] = 1000
default['chef-compliance']['nginx']['gzip_disable'] = 'MSIE [1-6]\.'
default['chef-compliance']['nginx']['keepalive'] = 'on'
default['chef-compliance']['nginx']['keepalive_timeout'] = 65
default['chef-compliance']['nginx']['keepalive_requests']   = 100
default['chef-compliance']['nginx']['worker_processes'] = node['cpu'] && node['cpu']['total'] ? node['cpu']['total'] : 1
default['chef-compliance']['nginx']['worker_connections'] = 1024
default['chef-compliance']['nginx']['worker_rlimit_nofile'] = nil
default['chef-compliance']['nginx']['multi_accept'] = false
default['chef-compliance']['nginx']['event'] = nil
default['chef-compliance']['nginx']['server_tokens'] = nil
default['chef-compliance']['nginx']['server_names_hash_bucket_size'] = 128
default['chef-compliance']['nginx']['variables_hash_max_size']       = 1024
default['chef-compliance']['nginx']['variables_hash_bucket_size']    = 64
default['chef-compliance']['nginx']['sendfile'] = 'on'
default['chef-compliance']['nginx']['access_log_options'] = nil
default['chef-compliance']['nginx']['error_log_options'] = nil
default['chef-compliance']['nginx']['disable_access_log'] = false
default['chef-compliance']['nginx']['default_site_enabled'] = false
default['chef-compliance']['nginx']['types_hash_max_size'] = 2048
default['chef-compliance']['nginx']['types_hash_bucket_size'] = 64
default['chef-compliance']['nginx']['proxy_read_timeout'] = nil
default['chef-compliance']['nginx']['client_body_buffer_size'] = nil
default['chef-compliance']['nginx']['client_max_body_size'] = '250m'
default['chef-compliance']['nginx']['default']['modules'] = []
default['chef-compliance']['nginx']['extra_configs'] = {}
default['chef-compliance']['nginx']['tcp_nodelay'] = 'on'
default['chef-compliance']['nginx']['tcp_nopush'] = 'on'
default['chef-compliance']['nginx']['access_by_lua_file'] = false
default['chef-compliance']['nginx']['strict_host_header'] = false
default['chef-compliance']['nginx']['use_implicit_hosts'] = false

# Postgres
default['chef-compliance']['postgresql']['enable'] = true
default['chef-compliance']['postgresql']['username'] = 'chef-pgsql'
default['chef-compliance']['postgresql']['shell'] = shell
default['chef-compliance']['postgresql']['home'] = "/var/opt/chef-compliance/postgresql"
default['chef-compliance']['postgresql']['user_path'] = "/opt/chef-compliance/embedded/bin:/opt/chef-compliance/bin:$PATH"
default['chef-compliance']['postgresql']['data_directory'] = '/var/opt/chef-compliance/postgresql/9.5/data'
default['chef-compliance']['postgresql']['log_directory'] = "#{node['chef-compliance']['log_directory']}/postgresql"
default['chef-compliance']['postgresql']['log_rotation']['file_maxbytes'] = 104857600
default['chef-compliance']['postgresql']['log_rotation']['num_to_keep'] = 10
default['chef-compliance']['postgresql']['checkpoint_completion_target'] = 0.5
default['chef-compliance']['postgresql']['checkpoint_segments'] = 3
default['chef-compliance']['postgresql']['checkpoint_timeout'] = '5min'
default['chef-compliance']['postgresql']['checkpoint_warning'] = '30s'
default['chef-compliance']['postgresql']['effective_cache_size'] = '128MB'
default['chef-compliance']['postgresql']['listen_address'] = '127.0.0.1'
default['chef-compliance']['postgresql']['max_connections'] = 350
default['chef-compliance']['postgresql']['md5_auth_cidr_addresses'] = ['127.0.0.1/32', '::1/128']
default['chef-compliance']['postgresql']['port'] = 5432
default['chef-compliance']['postgresql']['shared_buffers'] = "#{(node['memory']['total'].to_i / 4) / (1024)}MB"
default['chef-compliance']['postgresql']['shmmax'] = 17179869184
default['chef-compliance']['postgresql']['shmall'] = 4194304
default['chef-compliance']['postgresql']['work_mem'] = '8MB'

default['chef-compliance']['postgresql']['external'] = false
default['chef-compliance']['postgresql']['db_superuser'] = 'postgres'
default['chef-compliance']['postgresql']['db_superuser_password'] = nil
default['chef-compliance']['postgresql']['vip'] = "127.0.0.1"
default['chef-compliance']['postgresql']['port'] = 5432

# SSL
default['chef-compliance']['ssl']['enable'] = true
default['chef-compliance']['ssl']['directory'] = '/var/opt/chef-compliance/ssl'
default['chef-compliance']['ssl']['ca_directory'] = '/var/opt/chef-compliance/ssl/ca'
default['chef-compliance']['ssl']['certificate'] = nil
default['chef-compliance']['ssl']['certificate_key'] = nil
default['chef-compliance']['ssl']['ssl_dhparam'] = nil
default['chef-compliance']['ssl']['country_name'] = 'US'
default['chef-compliance']['ssl']['state_name'] = 'OR'
default['chef-compliance']['ssl']['locality_name'] = 'Portland'
default['chef-compliance']['ssl']['company_name'] = 'My chef-compliance'
default['chef-compliance']['ssl']['organizational_unit_name'] = 'Devops Unicorns'
default['chef-compliance']['ssl']['email_address'] = 'you@example.com'
default['chef-compliance']['ssl']['ciphers'] = 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA'
default['chef-compliance']['ssl']['protocols'] = 'TLSv1 TLSv1.1 TLSv1.2'
default['chef-compliance']['ssl']['session_cache'] = 'shared:SSL:4m'
default['chef-compliance']['ssl']['session_timeout'] = '5m'

default['chef-compliance']['core']['enable'] = true
default['chef-compliance']['core']['mode'] = 'setup' # or 'default'
default['chef-compliance']['core']['directory'] = '/var/opt/chef-compliance/core'
default['chef-compliance']['core']['vip'] = '127.0.0.1'
default['chef-compliance']['core']['port'] = 10500
default['chef-compliance']['core']['env_directory'] = "/opt/chef-compliance/service/core/env"
default['chef-compliance']['core']['log_directory'] = "#{node['chef-compliance']['log_directory']}/core"
default['chef-compliance']['core']['log_rotation']['file_maxbytes'] = 104857600
default['chef-compliance']['core']['log_rotation']['num_to_keep'] = 10
default['chef-compliance']['core']['detect_timeout'] = 30
default['chef-compliance']['core']['scan_timeout'] = 1800
default['chef-compliance']['core']['update_timeout'] = 1800
default['chef-compliance']['core']['sql_user'] = "chef_compliance"
default['chef-compliance']['core']['sql_password'] = nil
default['chef-compliance']['core']['sql_ro_user'] = "chef_compliance_ro"
default['chef-compliance']['core']['sql_ro_password'] = nil

default['chef-compliance']['core']['oidc_client_id'] = nil
default['chef-compliance']['core']['oidc_client_secret'] = nil

default['chef-compliance']['dex']['enable'] = true
default['chef-compliance']['dex']['key_secrets'] = nil
default['chef-compliance']['dex']['sql_password'] = nil
default['chef-compliance']['dex']['sql_user'] = 'dex'
default['chef-compliance']['dex']['sql_ro_user'] = 'dex_ro'
default['chef-compliance']['dex']['sql_ro_password'] = nil

default['chef-compliance']['dex-worker']['vip'] = '127.0.0.1'
default['chef-compliance']['dex-worker']['port'] = 5556
default['chef-compliance']['dex-worker']['user'] = 'dex-worker'
default['chef-compliance']['dex-worker']['group'] = 'dex-worker'
default['chef-compliance']['dex-worker']['home'] = '/opt/chef-compliance/embedded/service/dex-worker'
default['chef-compliance']['dex-worker']['parameters']['html_assets'] = "#{node['chef-compliance']['dex-worker']['home']}/static/html"
default['chef-compliance']['dex-worker']['parameters']['email_cfg'] = "#{node['chef-compliance']['dex-worker']['home']}/static/fixtures/emailer.json"
default['chef-compliance']['dex-worker']['parameters']['listen'] = "http://#{node['chef-compliance']['dex-worker']['vip']}:#{node['chef-compliance']['dex-worker']['port']}"
default['chef-compliance']['dex-worker']['parameters']['issuer'] = 'https://%%FQDN%%'
default['chef-compliance']['dex-worker']['parameters']['issuer_logo_url'] = 'https://%%FQDN%%/images/logo-compliance.png'
default['chef-compliance']['dex-worker']['parameters']['issuer_name'] = 'Chef Compliance'
default['chef-compliance']['dex-worker']['env_directory'] = "/opt/chef-compliance/service/dex-worker/env"
default['chef-compliance']['dex-worker']['log_directory'] = "#{node['chef-compliance']['log_directory']}/dex-worker"
default['chef-compliance']['dex-worker']['log_rotation']['file_maxbytes'] = 104_857_600
default['chef-compliance']['dex-worker']['log_rotation']['num_to_keep'] = 10

default['chef-compliance']['dex-overlord']['user'] = 'dex-overlord'
default['chef-compliance']['dex-overlord']['group'] = 'dex-overlord'
default['chef-compliance']['dex-overlord']['home'] = '/opt/chef-compliance/embedded/service/dex-overlord'
default['chef-compliance']['dex-overlord']['env_directory'] = "/opt/chef-compliance/service/dex-overlord/env"
default['chef-compliance']['dex-overlord']['log_directory'] = "#{node['chef-compliance']['log_directory']}/dex-overlord"
default['chef-compliance']['dex-overlord']['log_rotation']['file_maxbytes'] = 104_857_600
default['chef-compliance']['dex-overlord']['log_rotation']['num_to_keep'] = 10
