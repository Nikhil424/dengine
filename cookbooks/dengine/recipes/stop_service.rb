
tomcat_service_sysvinit 'docs' do
  action [:stop]
  install_path '/opt/special/tomcat_docs/'
end
