name             'jenkins-master'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures jenkins-master'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
min_version = `git log -n 1 --pretty=format:'%ct' #{File.dirname(__FILE__)} 2> /dev/null`
version          '0.1.2' + min_version

depends 'jenkins'
depends 'pluginjenkins'
depends 'jenkins-config'
depends 'jenkins-job'
depends 'provision-dengine-dashboard'
