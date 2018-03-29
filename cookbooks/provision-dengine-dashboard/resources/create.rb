resource_name :directory_create

action :create do
  puts "NOTICE: creating .chef directory to create workstation"

  remote_directory '/root/.chef' do
    source 'plugins'
    owner 'root'
    group 'root'
    files_owner 'root'
    files_group 'root'
    files_mode 0644
    mode 0755
  end

  remote_directory '/var/lib/jenkins/.chef' do
    source 'plugins'
    owner 'root'
    group 'root'
    files_owner 'root'
    files_group 'root'
    files_mode 0644
    mode 0755
  end

  directory '/root/chef-repo' do
    owner 'root'
    group 'root'
    action :create
  end

  remote_directory "/root/chef-repo/.chef" do
    source 'dot-chef'
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

%w[/var/lib/jenkins/chef-repo/.chef/new-iac-coe.pem /var/lib/jenkins/chef-repo/.chef/google_key.ppk ].each do |keys|
    remote_file keys do
      source "file://#{keys}"
      mode '0400'
    end
  end


end
