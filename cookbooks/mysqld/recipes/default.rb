#
# Cookbook Name:: mysqld
# Recipe:: default
#
# Copyright 2013, Chris Aumann
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
execute "updating_apt" do
  command "apt-get update"
  user "root"
end

include_recipe 'mysqld::install'
include_recipe 'mysqld::configure'

cookbook_file "/home/ubuntu/nik.sql" do
  source "nik.sql.erb"
  mode "0644"
end

#execute "create database" do
# command "mysql -u root -proot123 -e 'create database mysql';"
#end

#execute "mysql1" do
#command "mysql -u root -pmysql < /home/ubuntu/nik.sql"
#end

#execute "mysql grant" do
#command <<-EOF
#mysql -u root -p -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY 'root123' WITH GRANT OPTION;"
#EOF
#end

#execute "mysql grant remote" do
#  command <<-EOF
#mysql -u root -proot123 -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root123';"
#EOF
#end
