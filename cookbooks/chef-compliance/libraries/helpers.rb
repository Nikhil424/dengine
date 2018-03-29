require 'openssl'

ENV['PATH'] = "/opt/chef-compliance/bin:/opt/chef-compliance/embedded/bin:#{ENV['PATH']}"

module ChefCompliance
  module Helpers
    def implicit_hosts
      @implicit_hosts ||= begin
                            hosts = [ "localhost", "127.0.0.1" ]
                            hosts << "::1" if ipv6?

                            hosts << local_ip_addresses
                            if node['cloud']
                              hosts << node['cloud']['public_ips'] if node['cloud']['public_ips']
                              hosts << node['cloud']['private_ips'] if node['cloud']['private_ips']
                            end
                            hosts.flatten.uniq.join(" ")
                          end
    end

    def ipv6?
      node['chef-compliance']['ip_version'] == 'ipv6'
    end

    def local_ip_addresses
      ret = []
      node['network']['interfaces'].each do |name, iface|
        next unless iface["addresses"].respond_to?(:each)
        iface["addresses"].each do |addr, addr_info|
          if addr_info["family"] == "inet"
            ret << addr
          elsif addr_info["family"] == "inet6" && ipv6?
            ret << addr
          end
        end
      end
      ret
    end

    def nginx_server_names
      if node['chef-compliance']['nginx']['use_implicit_hosts']
        "#{node['chef-compliance']['nginx']['server_name']} #{implicit_hosts}"
      else
        node['chef-compliance']['nginx']['server_name']
      end
    end
  end
end

if defined?(Chef)
  Chef::Recipe.send(:include, ChefCompliance::Helpers)
  Chef::Provider.send(:include, ChefCompliance::Helpers)
  Chef::Resource.send(:include, ChefCompliance::Helpers)
  Chef::ResourceDefinition.send(:include, ChefCompliance::Helpers)
end
