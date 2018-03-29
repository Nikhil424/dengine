include ComponentRunitSupervisorResourceMixin

provides :component_runit_supervisor do |node|
  node['init_package'] == 'systemd'
end

action :create do
  template "/etc/systemd/system/#{unit_name}" do
    cookbook 'enterprise'
    owner 'root'
    group 'root'
    mode '0644'
    variables(install_path: new_resource.install_path,
              project_name: new_resource.name)
    source 'runsvdir-start.service.erb'
  end

  # This cookbook originally installed its unit files in /usr/lib/systemd/system.
  execute 'cleanup_old_unit_files' do
    command <<-EOH
              rm /usr/lib/systemd/system/#{unit_name}
              systemctl daemon-reload
    EOH
    only_if { ::File.exist?("/usr/lib/systemd/system/#{unit_name}") }
  end

  service unit_name do
    action [:enable, :start]
    provider Chef::Provider::Service::Systemd
  end
end

action :delete do
  Dir["#{new_resource.install_path}/service/*"].each do |svc|
    execute "#{new_resource.install_path}/embedded/bin/sv stop #{svc}" do
      retries 5
      only_if { ::File.exist? "#{new_resource.install_path}/embedded/bin/sv" }
    end
  end

  service unit_name do
    action [:stop, :disable]
    provider Chef::Provider::Service::Systemd
  end

  file "/etc/systemd/system/#{unit_name}" do
    action :delete
  end
end

action_class do
  def unit_name
    "#{new_resource.name}-runsvdir-start.service"
  end
end
