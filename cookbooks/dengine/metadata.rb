name             'dengine'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures dengine'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
min_version = `git log -n 1 --pretty=format:'%ct' #{File.dirname(__FILE__)} 2> /dev/null`
version          '0.1.2' + min_version

gem "artifactory"
depends 'dengine_tomcat'
