
tomcat_service_sysvinit 'docs' do
  action [:start, :enable]
  install_path '/opt/special/tomcat_docs/'
end
