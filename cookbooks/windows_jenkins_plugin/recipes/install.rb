


jenkins_plugin 'disk-usage' do
#   source 'http://updates.jenkins-ci.org/download/plugins/disk-usage/0.28/disk-usage.hpi'
   install_deps false
#   options '-deploy'
end

jenkins_plugin 'ant' do
  source'http://updates.jenkins-ci.org/download/plugins/ant/1.5/ant.hpi'
  install_deps false
end

jenkins_plugin 'artifactory' do
 source 'http://updates.jenkins-ci.org/download/plugins/artifactory/2.10.4/artifactory.hpi'
  install_deps false
end

jenkins_plugin 'bouncycastle-api' do
  source 'http://updates.jenkins-ci.org/download/plugins/bouncycastle-api/2.16.1/bouncycastle-api.hpi'
  install_deps false
end



jenkins_plugin 'buildresult-trigger' do
 source 'http://updates.jenkins-ci.org/download/plugins/buildresult-trigger/0.17/buildresult-trigger.hpi'
  install_deps false
end



jenkins_plugin 'config-file-provider' do
  source 'http://updates.jenkins-ci.org/download/plugins/config-file-provider/2.15.7/config-file-provider.hpi'
  install_deps false
end


jenkins_plugin 'credentials' do
  source 'http://updates.jenkins-ci.org/download/plugins/credentials/2.1.13/credentials.hpi'
  install_deps false
end


jenkins_plugin 'deploy' do
  source 'http://updates.jenkins-ci.org/download/plugins/deploy/1.10/deploy.hpi'
  install_deps false
end

jenkins_plugin 'sonar' do
 source 'http://updates.jenkins-ci.org/download/plugins/sonar/2.6.1/sonar.hpi'
  install_deps false
end


jenkins_plugin 'display-url-api' do
 source 'http://updates.jenkins-ci.org/download/plugins/display-url-api/2.0/display-url-api.hpi'
  install_deps false
end


jenkins_plugin 'git-client' do
  source 'http://updates.jenkins-ci.org/download/plugins/git-client/2.4.5/git-client.hpi'
  install_deps false
end

jenkins_plugin 'git' do
  source 'http://updates.jenkins-ci.org/download/plugins/git/3.3.0/git.hpi'
  install_deps false
end


jenkins_plugin 'github-api' do
 source 'http://updates.jenkins-ci.org/download/plugins/github-api/1.85/github-api.hpi'
  install_deps false
end


#jenkins_plugin 'github-pullrequest' do
#  version '0.1.0-rc24'
#  install_deps false
#end


jenkins_plugin 'github' do
  source 'http://updates.jenkins-ci.org/download/plugins/github/1.27.0/github.hpi'
  install_deps false
end


jenkins_plugin 'gradle' do
source 'http://updates.jenkins-ci.org/download/plugins/gradle/1.26/gradle.hpi'
  install_deps false
end


jenkins_plugin 'icon-shim' do
source 'http://updates.jenkins-ci.org/download/plugins/icon-shim/2.0.3/icon-shim.hpi'
  install_deps false
end


jenkins_plugin 'ivy' do
source 'http://updates.jenkins-ci.org/download/plugins/ivy/1.27.1/ivy.hpi'
  install_deps false
end


jenkins_plugin 'javadoc' do
source 'http://updates.jenkins-ci.org/download/plugins/javadoc/1.4/javadoc.hpi'
  install_deps false
end

jenkins_plugin 'ace-editor' do
#source '
  version '1.1'
  install_deps false
end

jenkins_plugin 'jquery-detached' do
#source '
  version '1.2.1'
  install_deps false
end

jenkins_plugin 'junit' do
#source '
  version '1.20'
  install_deps false
end

jenkins_plugin 'mailer' do
source 
  version '1.20'
  install_deps false
end

jenkins_plugin 'matrix-auth' do
source 
  version '1.5'
  install_deps false
end

jenkins_plugin 'matrix-project' do
  version '1.10'
  install_deps false
end

jenkins_plugin 'maven-plugin' do
  version '2.15.1'
  install_deps false
end

jenkins_plugin 'antisamy-markup-formatter' do
  version '1.5'
  install_deps true
end


jenkins_plugin 'workflow-api' do
  version '2.13'
  install_deps false
end


jenkins_plugin 'workflow-cps' do
  version '2.13'
  install_deps false
end


jenkins_plugin 'workflow-scm-step' do
  version '2.4'
  install_deps false
end


jenkins_plugin 'workflow-step-api' do
  version '2.9'
  install_deps false
end

jenkins_plugin 'workflow-support' do
  version '2.14'
  install_deps false
end

jenkins_plugin 'plain-credentials' do
  version '1.4'
  install_deps false
end

jenkins_plugin 'scm-api' do
  version '2.1.1'
  install_deps false
end

jenkins_plugin 'script-security' do
  version '1.27'
  install_deps false
end

jenkins_plugin 'ssh-credentials' do
  version '1.13'
  install_deps false
end


jenkins_plugin 'structs' do
  version '1.6'
  install_deps false
end


jenkins_plugin 'token-macro' do
  version '2.1'
  install_deps false
end

 
jenkins_plugin 'msbuild' do
  version '1.27'
  install_deps false
end

jenkins_plugin 'windows-slaves' do
  version '1.3.1'
  install_deps false
  options '-restart'
end

batch 'jenkins-restart' do
   cwd 'C:\Program Files (x86)\Jenkins'
   code <<-EOH
    jenkins.exe restart
    EOH

end
