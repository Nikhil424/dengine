require 'chef/dsl'
require 'fileutils'
require 'chef/knife'

  include Chef::DSL::IncludeRecipe

module PostDeploy

  def work_post_deploy
    FileUtils.rm_rf "/var/www/html"
#    FileUtils.cp_r "/var/deploy/current/backup_html", "/var/www/"
  end

end
