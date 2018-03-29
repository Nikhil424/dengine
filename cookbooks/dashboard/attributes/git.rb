# Setting attributes to sync chef-repo

default['dashboard']['git'].tap do |git|

  git['destination'] = '/var/lib/jenkins'
  git['ssh_wrapper'] = '/var/deploy/wrap-ssh4git.sh'
  git['revision']    = 'master'
  git['action']      = ':sync'

end
