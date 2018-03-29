require "#{File.dirname(__FILE__)}/base/dengine_azurerm_base"

class Chef
  class Knife
    class DengineAzureServerList < Knife

      include Knife::DengineAzurermBase

      banner "knife dengine azure server list (options)"

      def run
        $stdout.sync = true
        validate_arm_keys!
        begin
          service.list_servers(locate_config_value(:azure_resource_group_name))
        rescue => error
          service.common_arm_rescue_block(error)
        end
      end
    end
  end
end
