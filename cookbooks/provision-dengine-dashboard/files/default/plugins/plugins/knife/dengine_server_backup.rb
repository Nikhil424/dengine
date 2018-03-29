require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_azure_interface"
require "#{File.dirname(__FILE__)}/base/dengine_aws_interface"
require "#{File.dirname(__FILE__)}/base/dengine_google_interface"
require "#{File.dirname(__FILE__)}/base/dengine_data_tresure"

module Engine
  class DengineServerBackup < Chef::Knife

    include DengineDataTresure

    banner 'knife dengine server backup (options)'

      option :instance_id,
        :short => '-i INSTANCE_ID',
        :long => '--instance_id INSTANCE_ID',
        :description => 'The instance id of the machine from whom the image has to be captured'

      option :name,
        :short => '-n IMAGE_NAME',
        :long => '--name IMAGE_NAME',
        :description => 'Give the name for the image you capture '

      option :description,
        :short => '-d DESCRIPTION',
        :long => '--description DESCRIPTION',
        :description => 'The deccription for the image that is getting captured',
        :default => "This is the image of server"

      option :cloud,
        :long => '--cloud CLOUD_PROVIDER_NAME',
        :description => "The name of the cloud provider for ex: aws, azure, google, openstack etc"

      def run

        if config[:cloud] == "aws"
          @client = DengineAwsInterface.new
        elsif config[:cloud] == "azure"
          puts "#{ui.color('we are in alfa, soon we will be here', :cyan)}"
          exit
          @client = ''
        elsif config[:cloud] == "google"
          puts "#{ui.color('we are in alfa, soon we will be here', :cyan)}"
          exit
          @client = ''
        elsif config[:cloud] == "openstack"
          puts "#{ui.color('we are in alfa, soon we will be here', :cyan)}"
          exit
          @client = ''
        elsif (config[:cloud].nil?)
          Chef::Log.error "You have misspell the word or you might have not chose the cloud provider "
          exit
        end

      capture_image

      end

      def capture_image

        image_name = config[:name]

        if config[:cloud] == "aws"

          @client.create_image("#{config[:instance_id]}",image_name,"#{config[:description]}")

        elsif config[:cloud] == "azure"
        elsif config[:cloud] == "google"
        elsif config[:cloud] == "openstack"
        elsif (config[:cloud].nil?)
          Chef::Log.error "You have misspell the word or you might have not chose the cloud provider "
          exit
        end

      end

  end
end
