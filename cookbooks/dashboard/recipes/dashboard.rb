include_recipe 'copy-jenkins::default'
include_recipe 'jenkins::master'

include_recipe 'copy-jenkins::remove'
#include_recipe 'dashboard::dashboard-machine'
