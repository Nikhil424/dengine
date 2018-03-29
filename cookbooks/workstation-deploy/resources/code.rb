resource_name :deploy_dengine_ui

#The piece of code which takes care of the deployment in case needed.
action :deploy do
  deploy 'dengineui_repo' do
    repo 'git@bitbucket.org:devopsiac/dengineui.git'
    user 'root'
    deploy_to '/var/deploy'
    purge_before_symlink nil
    symlink_before_migrate ({})
    enable_checkout false
    action :deploy
    keep_releases 5
    symlinks ({})
    rollback_on_error true
    ssh_wrapper '/var/deploy/wrap-ssh4git.sh'
  end
end

#The piece of code which takes care of the rollback in case needed.
action :rollback do
  deploy 'dengineui_repo' do
    repo 'git@bitbucket.org:devopsiac/dengineui.git'
    user 'root'
    deploy_to '/var/deploy'
    purge_before_symlink nil
    symlink_before_migrate ({})
    enable_checkout false
    action :rollback
    keep_releases 5
    symlinks ({})
    rollback_on_error true
    ssh_wrapper '/var/deploy/wrap-ssh4git.sh'
  end
end
