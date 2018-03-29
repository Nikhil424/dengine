#
# Cookbook Name:: apt_install
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

execute "add-apt-repository ppa:openjdk-r/ppa"

execute "apt-get update"

