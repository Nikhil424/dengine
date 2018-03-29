resource_name :dot_chef

action :create do
  Chef::Log.info("**")
  Chef::Log.info("NOTICE: creating .chef directory to create workstation")
  Chef::Log.info("**")

  remote_directory '/var/lib/jenkins/.chef' do
    source 'plugins'
    owner 'root'
    group 'root'
    files_owner 'root'
    files_group 'root'
    files_mode 0644
    mode 0755
  end

  remote_directory "/var/lib/jenkins/chef-repo/.chef" do
    source 'dot-chef'
    owner 'root'
    group 'root'
    files_owner 'root'
    files_group 'root'
    files_mode 0644
    mode 0755
  end

end
