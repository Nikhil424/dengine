#
# Cookbook Name:: dotnet
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "windows"
include_recipe 'iis::default'

directory 'C:\application' do
  rights :full_control, 'Everyone'
  recursive true
  action :create
end

cookbook_file 'C:\application\jdk-8u131-windows-x64.zip' do
  source "jdk-8u131-windows-x64.zip"
  rights :full_control, 'Everyone'
  action :create
end

cookbook_file 'C:\application\BuildTools_Full.zip' do
  source "BuildTools_Full.zip"
  rights :full_control, 'Everyone'
  action :create
end

cookbook_file 'C:\application\jenkins.msi' do
  source "jenkins.msi"
  rights :full_control, 'Everyone'
  action :create
 
end

windows_package 'jenkins' do
  source 'C:\application\jenkins.msi'
  options '/Q'
#  options 'jenkins.install.runSetupWizard=false'
  action :install
end

cookbook_file 'C:\application\WebDeploy_amd64_en-US.msi' do
  source "WebDeploy_amd64_en-US.msi"
  rights :full_control, 'Everyone'
  action :create

end

cookbook_file 'C:\application\config-job.xml' do
  source "config-job.xml"
  rights :full_control, 'Everyone'
  action :create
end

cookbook_file 'C:\application\Git-2.13.2-64-bit.zip' do
  source "Git-2.13.2-64-bit.zip"
  rights :full_control, 'Everyone'
  action :create
end

cookbook_file 'C:\application\nuget.zip' do
  source "nuget.zip"
  rights :full_control, 'Everyone'
  action :create
end

cookbook_file 'C:\application\Reference Assemblies.zip' do
  source "Reference_Assemblies.zip"
  rights :full_control, 'Everyone'
  action :create
end

cookbook_file 'C:\application\Microsoft.zip' do
  source "Microsoft.zip"
  rights :full_control, 'Everyone'
  action :create
end

#seven_zip_archive 'C:\nik\Microsoft.zip' do
#  path      'C:\Program Files (x86)\MSBuild'
#  source    'C:\nik\Microsoft.zip'
#  overwrite true
#end

windows_zipfile 'C:\Program Files (x86)\MSBuild' do
  source 'C:\application\Microsoft.zip'
  action :unzip
end

windows_zipfile 'C:\Program Files (x86)' do
  source 'C:\application\Reference Assemblies.zip'
  action :unzip
end

windows_zipfile 'C:\application' do
  source 'C:\application\jdk-8u131-windows-x64.zip'
  action :unzip
end

windows_zipfile 'C:\application' do
  source 'C:\application\Git-2.13.2-64-bit.zip'
  action :unzip
end

windows_zipfile 'C:\application' do
  source 'C:\application\nuget.zip'
  action :unzip
end

windows_zipfile 'C:\application' do
  source 'C:\application\BuildTools_Full.zip'
  action :unzip
end

# Create runi
windows_package 'jdk' do
  source 'C:\application\jdk-8u131-windows-x64.exe'
  checksum '5083590a30bf069e947dce8968221af21b39836fe013b111de70d6107b577cd3'
  action :install
#  only_if {File.exists?("C:\Program Files\Java\jre1.8.0_131")}
end

execute 'set path' do
  command <<-EOF
setx Path "C:\\Program Files\\Java\\jre1.8.0_131\\bin"
EOF
  only_if { ENV['Path'] != 'C:\Program Files\Java\jre1.8.0_131\bin' }
end

execute 'set java_home' do
  command <<-EOF
setx JAVA_HOME "C:\\Program Files\\Java\\jre1.8.0_131"
EOF
  only_if { ENV['JAVA_HOME'] != 'C:\Program Files\Java\jre1.8.0_131' }
end

execute 'set opts ' do
  command <<-EOF
setx -m JAVA_OPTS "-Djenkins.install.runSetupWizard=false"
EOF
end

windows_package 'msbuild' do

  source 'C:\application\BuildTools_Full.exe'
 # checksum '92cfb3de1721066ff5a93f14a224cc26f839969706248b8b52371a8c40a9445b'
  installer_type :custom
  options '/Q'
  action :install
end
windows_package 'webdeploy' do

  source 'C:\application\WebDeploy_amd64_en-US.msi'
 # checksum '92cfb3de1721066ff5a93f14a224cc26f839969706248b8b52371a8c40a9445b'
  installer_type :custom
  options '/Q'
  action :install
end


windows_package 'jenkins' do
  source 'C:\application\jenkins.msi'
  options '/Q'
#  options 'jenkins.install.runSetupWizard=false'
  action :install
end

# Include runit to setup the se


# Create ru

windows_package 'git' do

  source 'C:\application\Git-2.13.2-64-bit.exe'
  checksum '7ac1e1c3b8ed1ee557055047ca03b1562de70c66f8fd1a90393a5405e1f1967b'
  installer_type :custom
  options '/SILENT'
  action :install
#   only_if {File.exists?("C:\Program Files\Git")}
end

cookbook_file 'C:\Program Files (x86)\Jenkins\jenkins.install.InstallUtil.lastExecVersion' do
  source "jenkins.install.InstallUtil.lastExecVersion"
  rights :full_control, 'Everyone'
  action :create
end

cookbook_file 'C:\Program Files (x86)\Jenkins\config.xml' do
  source "config.xml"
  rights :full_control, 'Everyone'
  action :create
end

cookbook_file 'C:\Program Files (x86)\Jenkins\hudson.plugins.msbuild.MsBuildBuilder.xml' do
  source "hudson.plugins.msbuild.MsBuildBuilder.xml"
  rights :full_control, 'Everyone'
  action :create
end

batch 'jenkins-restart' do
   cwd 'C:\Program Files (x86)\Jenkins'
   code <<-EOH
    jenkins.exe restart
    EOH
  
end

include_recipe 'windows_jenkins_plugin::install'
job_config = "C:\\application\\config-job.xml"

job_name="dotnet"

jenkins_job job_name do
 config job_config

 action :create
end

powershell_script 'install_resource' do
  code 'Install-WindowsFeature Web-Net-Ext'
end

powershell_script 'install_resource' do
  code 'Install-WindowsFeature Web-Net-Ext45'
end

powershell_script 'install_resource' do
  code 'Install-WindowsFeature Web-ASP'
end

powershell_script 'install_resource' do
  code 'Install-WindowsFeature Web-ASP-Net'
end

powershell_script 'install_resource' do
  code 'Install-WindowsFeature Web-ASP-Net45'
end

powershell_script 'install_resource' do
  code 'Install-WindowsFeature Web-ISAPI-Ext'
end

powershell_script 'install_resource' do
  code 'Install-WindowsFeature Web-ISAPI-Filter'
end

powershell_script 'install_resource' do
  code 'Install-WindowsFeature Web-Includes'
end

powershell_script 'install_resource' do
  code 'Install-WindowsFeature Web-WebSockets'
end


# first the physical location must exist

# now create and start the site (note this will use the default application pool which must exist)

