#
# Cookbook Name:: configure_windows
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

windows_package 'Notepad++ Installer 64-bit x64' do
  source 'https://notepad-plus-plus.org/repository/7.x/7.3.2/npp.7.3.2.Installer.x64.exe'
  installer_type :custom
  options '/S'
end

windows_package '7-Zip 16.04 (x64 edition)' do
  source 'http://www.7-zip.org/a/7z1604-x64.exe'
  installer_type :custom
  options '/S'
end
