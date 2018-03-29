require 'chef/dsl'
require 'fileutils'
require 'chef/knife'

  include Chef::DSL::IncludeRecipe

module PostDeploy

  def post_deploy_act(app_name,art_version,roll_version)
    Chef::Log.info("Performing post deployment activity please hold for a moment")
    Chef::Log.info("====================================")
    Chef::Log.info("Stoping the service of tomact")
    stop_service
    Chef::Log.info("====================================")
    if (check_previous(app_name,roll_version) == true)
      Chef::Log.info("====================================")
      Chef::Log.info("Cleaning up the previous deployment's mess")
      FileUtils.rm_rf "/opt/tomcat_docs/webapps/#{app_name}-#{roll_version}.war"
      FileUtils.rm_rf "/opt/tomcat_docs/webapps/#{app_name}-#{roll_version}"
      Chef::Log.info("Deployment cleanup is complete")
      Chef::Log.info("====================================")
    else
      Chef::Log.info("This is the fresh deployment")
    end
    Chef::Log.info("The deployment in progress")
    FileUtils.cp_r "/var/deploy/tmp/#{app_name}-#{art_version}.war", '/opt/tomcat_docs/webapps'
    Chef::Log.info("The deployment in complete")
    Chef::Log.info("====================================")
    Chef::Log.info("Starting the service of tomact")
    start_service
    Chef::Log.info("====================================")
    Chef::Log.info("Clean up in progress")
    clean_up(app_name,roll_version)
    Chef::Log.info("Cleaning up complete")
  end

  def stop_service
    include_recipe 'dengine::stop_service'
  end

  def start_service
    include_recipe 'dengine::start_service'
  end

  def clean_up(app_name,roll_version)
    FileUtils.rm_rf('/var/deploy/tmp')
    if File.exist?("/var/deploy/current/#{app_name}-#{roll_version}.war") == true
      File.delete("/var/deploy/current/#{app_name}-#{roll_version}.war")
    else
      Chef::Log.info("This is the fresh deployment")
    end
  end

  def check_current(app_name,art_version)
    if File.exist? "/opt/tomcat_docs/webapps/#{app_name}-#{art_version}.war"
      return true
    else
      return false
    end
  end

  def check_previous(app_name,roll_version)
    if File.exist? "/opt/tomcat_docs/webapps/#{app_name}-#{roll_version}.war"
      return true
    else
      return false
    end
  end

end
