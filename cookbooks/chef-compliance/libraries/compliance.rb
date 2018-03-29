require 'mixlib/config'
require 'chef/json_compat'
require 'chef/mash'
require 'securerandom'

module Compliance
  extend(Mixlib::Config)

  config_context :nginx
  config_context :postgresql
  config_context :ssl
  config_context :user
  config_context :core
  config_context :dex
  config_context :chef_gate
  config_context :setup do
    config_context :registration do
      default :required, false
    end
  end

  default :topology, 'standalone'
  default :ip_version, 'ipv4'
  default :servers, Mash.new

  configurable :fqdn

  class << self
    def from_file(filename)
      # We're overriding this here so that we can get more meaningful errors from
      # the reconfigure chef run; we don't particularly care what line in the chef
      # recipes is failing to evaluate the loaded file (in the case of what
      # originally triggered this, chef-compliance.rb), what we care about is which
      # line in the loaded file is causing the error.
      instance_eval(IO.read(filename), filename, 1)
    rescue
      raise "Error loading file: #{$!.backtrace[0]}: #{$!.message}"
    end

    # Using `lookup` to avoid `undefined method [] for nil` error
    def lookup(model, key, *rest)
      v = model[key]
      if rest.empty?
        v
      else
        v && lookup(v, *rest)
      end
    end

    # guards against creating secrets on non-bootstrap node
    def generate_hex(chars)
      SecureRandom.hex(chars)
    end

    def generate_dex_key_secret(n)
      SecureRandom.base64(n)
    end

    def lookup_or_generate_secrets(secrets_file = '/etc/chef-compliance/chef-compliance-secrets.json')

      secrets_json = {}
      if File.exist?(secrets_file)
        # Not using Mixlib's merge! because it overrides the contexts defined in chef-compliance.rb
        secrets_json = Chef::JSONCompat.from_json(File.read(secrets_file), symbolize_names: true)
      end

      # secrect for core
      core.sql_password = lookup(secrets_json, :core, :sql_password) || generate_hex(50)
      core.sql_ro_password = lookup(secrets_json, :core, :sql_ro_password) || generate_hex(50)
      postgresql.db_superuser_password = lookup(secrets_json, :postgresql, :db_superuser_password) || generate_hex(50)

      # secrets for dex
      dex.key_secrets = lookup(secrets_json, :dex, :key_secrets) || [generate_dex_key_secret(32)]
      dex.sql_password = lookup(secrets_json, :dex, :sql_password) || generate_hex(50)
      dex.sql_ro_password = lookup(secrets_json, :dex, :sql_ro_password) || generate_hex(50)
      core.oidc_client_id ||= lookup(secrets_json, :core, :oidc_client_id)
      core.oidc_client_secret ||= lookup(secrets_json, :core, :oidc_client_secret)

      # shared secret with chef-gate
      chef_gate.shared_secret ||= lookup(secrets_json, :chef_gate, :shared_secret)
    end

    def save_secrets(secrets_file = '/etc/chef-compliance/chef-compliance-secrets.json')
      if File.directory?('/etc/chef-compliance')
        File.open(secrets_file, 'w') do |f|
          f.chmod(0600)
          f.puts(
            Chef::JSONCompat.to_json_pretty(
              'postgresql' => {
                'db_superuser_password' => postgresql.db_superuser_password
              },
              'core' => {
                'sql_password' => core.sql_password,
                'sql_ro_password' => core.sql_ro_password,
                'oidc_client_id' => core.oidc_client_id,
                'oidc_client_secret' => core.oidc_client_secret,
              },
              'dex' => {
                'key_secrets' => dex.key_secrets,
                'sql_password' => dex.sql_password,
                'sql_ro_password' => dex.sql_ro_password,
              },
              'chef_gate' => {
                 'shared_secret' => chef_gate.shared_secret,
              }
            )
          )
        end
      end
    end

    def configure_topology
      case topology
      when 'standalone' then configure_standalone
      end
    end

    def configure_standalone
      lookup_or_generate_secrets
    end

    def server(name, opts = {})
      servers[name] = Mash.new(opts)
    end

    def server_info
      msg = "Unable to find a corresponding server entry for '#{fqdn}' in /etc/chef-compliance/chef-compliance.rb"
      msg << "\n In order to use the '#{topology}' topology you must set this configuration"
      fail msg unless servers.key?(fqdn)
      servers[fqdn]
    end

    def generate_config(node_name)
      Compliance['fqdn'] ||= node_name
      nginx.server_name = fqdn
      configure_ip_version
      configure_topology
      save(true)
    end

    def configure_ip_version
      case ip_version
      when 'ipv4'
        # Under ipv4 default to 0.0.0.0 in order to ensure that
        # any service that needs to listen externally on back-end
        # does so.
        Compliance['default_listen_address'] = '0.0.0.0'
      when 'ipv6'
        Compliance['default_listen_address'] = '::'
      end
    end

    def dex_db_url
      "postgres://#{dex.sql_user}:#{dex.sql_password}@#{postgresql.listen_address}:#{postgresql.port}/dex?sslmode=disable"
    end
  end
end
