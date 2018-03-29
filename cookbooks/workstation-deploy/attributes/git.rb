# Setting attributes to sync chef-repo

default['dashboard']['git'].tap do |git|

  git['destination'] = '/var/lib/jenkins'
  git['ssh_wrapper'] = '/var/lib/jenkins/chef-repo/.chef'
  git['revision']    = 'master'
  git['action']      = ':sync'

end
