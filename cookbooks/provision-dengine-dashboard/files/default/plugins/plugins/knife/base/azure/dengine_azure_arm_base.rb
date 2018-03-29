module Azure::ARM
    module DengineAzureArmBase

      def get_vm_size(size_name)
        size_hash = { "ExtraSmall" => "Standard_A0", "Small" => "Standard_A1",
                      "Medium" => "Standard_A2", "Large" => "Standard_A3",
                      "ExtraLarge" => "Standard_A4" }
        size_hash[size_name]
      end
    end
end
