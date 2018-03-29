require 'chef/knife'

module Engine
    module DengineServerBase

      def get_env(env)

        data_item_env = Chef::DataBagItem.new
        data_item_env.data_bag("network")
        data_value_env = Chef::DataBagItem.load("network",env)
        data_env = data_value_env.raw_data['SUBNET-ID']

      end

      def get_security_group(env)
     
        data_item_sg = Chef::DataBagItem.new
        data_item_sg.data_bag("network")
        data_value_sg = Chef::DataBagItem.load("network",env)
        data_sg = data_value_sg.raw_data['SECURITY-ID']

      end

      def get_vpc_id(env)

        data_item_sg = Chef::DataBagItem.new
        data_item_sg.data_bag("network")
        data_value_sg = Chef::DataBagItem.load("network",env)
        data_sg = data_value_sg.raw_data['VPC-ID']

      end

      def get_subnet_id(env)

        data_item_sub = Chef::DataBagItem.new
        data_item_sub.data_bag("network")
        data_value_sub = Chef::DataBagItem.load("network",env)
        data_sub = data_value_sub.raw_data['SUBNET-ID']

        return data_sub
      end

  end
end
