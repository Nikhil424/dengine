require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_azure_interface"
require "#{File.dirname(__FILE__)}/base/dengine_aws_interface"
require "#{File.dirname(__FILE__)}/base/dengine_google_interface"

module Engine
    class DengineOriginCreate < Chef::Knife

    banner "knife dengine origin create (options)"

    option :what,
      :short => '-w TYPE_OF_RESOURCE',
      :long => '--what TYPE_OF_RESOURCE',
      :description => "The type of resource that has to be created ex: storage_account, resource_group"

    option :name,
      :short => '-n RESOURCE_NAME',
      :long => '--resource-name RESOURCE_NAME',
      :description => "The name of the resource that has to be created"

    option :resource_group,
      :long => '--resource-group RESOURCE_GROUP_NAME',
      :description => "The name of the resource group in which resource has to be created",
      :default => "Dengine"

    option :cloud,
        :long => '--cloud CLOUD_PROVIDER_NAME',
        :description => "The name of the cloud provider for ex: aws, azure, google, openstack etc"


    def run
      if config[:cloud] == "aws"
        @client = DengineAwsInterface.new
      elsif config[:cloud] == "azure"
        @client = DengineAzureInterface.new
      elsif config[:cloud] == "google"
        @client = DengineGoogleInterface.new
      elsif config[:cloud] == "openstack"
        puts "#{ui.color('we are in alfa, soon we will be here', :cyan)}"
        exit
        @client = ''
      elsif (config[:cloud].nil?)
        Chef::Log.error "You have misspell the word or you might have not chose the cloud provider "
        exit
      end

      create_resource

    end

    def create_resource

      if config[:cloud] == "aws"
        puts "#{ui.color('we have not found anything yet to create for the cloud you selected, if so has to be created inform us we will work on it', :cyan)}"
        exit
      elsif config[:cloud] == "azure"
        if  config[:what] == "resource_group"
          puts ""
          puts "#{ui.color('Creating resource group', :cyan)}"
          puts "."
          puts "#{ui.color('Resource group creation is in progress', :cyan)}"
          @client.create_resource_group("#{config[:name]}")
          puts "#{ui.color('Resource group creation is in completed', :cyan)}"
        elsif config[:what] == "storage_account"
          puts ""
          puts "#{ui.color('Creating resource group', :cyan)}"
          puts "."
          puts "#{ui.color('Storage account creation is in progress', :cyan)}"
          @client.create_storage_account("#{config[:resource_group]}","#{config[:name]}")
          puts "#{ui.color('Storage account creation is in completed', :cyan)}"
        else
          Chef::Log.error "I do not know the resource type you entered check if you have entered the valid resoure name, else talk to administrator "
        exit
        end
      elsif config[:cloud] == "google"
        puts "#{ui.color('we have not found anything yet to create for the cloud you selected, if so has to be created inform us we will work on it', :cyan)}"
        exit
      elsif config[:cloud] == "openstack"
        puts "#{ui.color('we have not found anything yet to create for the cloud you selected, if so has to be created inform us we will work on it', :cyan)}"
        exit
      elsif (config[:cloud].nil?)
        Chef::Log.error "You have misspell the word or you might have not chose the cloud provider "
        exit
      end
    end

  end
end
