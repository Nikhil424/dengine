
# Install Tomcat 7.0.44 to a custom path and install the example content / docs
tomcat_install 'docs' do
  version '8.5.15'
  exclude_examples false
  exclude_docs false
  install_path '/opt/special/tomcat_docs/'
end

# start the tomcat docs install as a sys-v init service (because we hate ourselves)
include_recipe 'dengine_tomcat::start_service'
