resource_name :chef_repo

action :create do
  Chef::Log.info("***")
  Chef::Log.info("*****")
  Chef::Log.info("NOTICE: creating the chef-repo...hold on to this...!")
  Chef::Log.info("*****")
  Chef::Log.info("***")

  repo = data_bag_item("dengine", "chef-repo")

  git node['dashboard']['git']['destination'] do 
    repository repo['url']
    reference  node['dashboard']['git']['revision'] || 'master'
    ssh_wrapper node['dashboard']['git']['ssh_wrapper']
    action :checkout
  end

end
