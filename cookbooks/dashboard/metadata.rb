name 'dashboard'
maintainer 'Nikhil Bhat'
maintainer_email 'nikhil.bhat@mindtree.com'
license 'All Rights Reserved'
description 'Installs/Configures workstation'
long_description 'Installs/Configures workstation'
min_version = `git log -n 1 --pretty=format:'%ct' #{File.dirname(__FILE__)} 2> /dev/null`
version  '0.1.2' + min_version
chef_version '>= 12.1' if respond_to?(:chef_version)

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/workstation/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/workstation'
depends 'git'
depends 'php'
depends 'jenkins'
depends 'webserver'
depends 'dengine_users'
depends 'copy-jenkins'
