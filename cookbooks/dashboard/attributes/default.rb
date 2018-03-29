#setting attributes to assign environment variable

default['workstation']['gcp'].tap do |gcp|
 
  gcp['app_credential_file']   = '/var/lib/jenkins/chef-repo/.chef/Project-ce1019e73f90.json'

end
