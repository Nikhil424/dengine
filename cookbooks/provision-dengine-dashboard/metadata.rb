name             'provision-dengine-dashboard'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures provision-dotchef'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
min_version = `git log -n 1 --pretty=format:'%ct' #{File.dirname(__FILE__)} 2> /dev/null`
version  '0.1.5' + min_version

gem 'artifactory'
depends 'jenkins'
depends 'dengine_users'
