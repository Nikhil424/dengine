require 'chef/knife'
require "#{File.dirname(__FILE__)}/dengine_client_base"

module Engine
    class DengineImageCreate < Chef::Knife

      include DengineClientBase

      banner 'knife dengine image create (options)'

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
        :default => "Tis is the image of server"

      def run

        instance_id = config[:instance_id]
        image_name  = config[:name]
        descrip     = config[:description]   

        image = create_image(instance_id,image_name,descrip)

        puts "#{ui.color('Printing the details of the resource created', :magenta)}"
        puts "#{ui.color('image_id', :magenta)}         : #{image}"

       end
        
       def create_image(instance_id,image_name,descrip)
         puts " "
         puts "#{ui.color('Capturing image of the server wit ID', :cyan)}: #{instance_id}"
         puts "."
         image = connection_client.create_image(instance_id: "#{instance_id}", name: "#{image_name}", description: "#{descrip}",)
         image_id = image.image_id
         connection_client.create_tags({ resources: ["#{image_id}"], tags: [{ key: 'Name', value: "#{image_name}" }]})
         puts ""
        
         return image_id
       end
        
      end
    end
