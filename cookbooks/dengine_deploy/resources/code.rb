resource_name :deploy_code

#This takes care of the deployment in case needed.

action :deploy do
Chef::Log.info("The environment of the node is : #{node.chef_environment}")
  deploy 'nikhil_repo' do
    repo 'file:///root/gameoflife-web-2.0-23.war'
    user 'root'
    deploy_to '/root/test_deploy/'
    purge_before_symlink nil
    symlink_before_migrate ({})
    enable_checkout false
    action :deploy
    keep_releases 5
    symlinks ({})
    rollback_on_error true
  end
end
