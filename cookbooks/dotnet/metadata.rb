name             'dotnet'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures dotnet'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.4.0'
depends "windows"
depends "jenkins_dotnet"
depends "iis"
depends "windows_jenkins_plugin"
