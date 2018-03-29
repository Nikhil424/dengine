name 'maven'
maintainer 'basniks'
maintainer_email 'basniktechi123@gmail.com'
license 'all_rights'
description 'Installs/Configures maven'
long_description 'Installs/Configures maven'
min_version = `git log -n 1 --pretty=format:'%ct' #{File.dirname(__FILE__)} 2> /dev/null`
version  '0.1.0' + min_version

# If you upload to Supermarket you should set this so your cookbook
# gets a `View Issues` link
# issues_url 'https://github.com/<insert_org_here>/maven/issues' if respond_to?(:issues_url)

# If you upload to Supermarket you should set this so your cookbook
# gets a `View Source` link
# source_url 'https://github.com/<insert_org_here>/maven' if respond_to?(:source_url)

depends 'tomcat'
