module CustomErrors
  class InterfaceNotImplementedError < NoMethodError
  end

  def self.included(klass)
    klass.send(:include, CustomErrors::Methods)
    klass.send(:extend, CustomErrors::Methods)
  end

  module Methods
     def api_not_implemented(klass)
      caller.first.match(/in \`(.+)\'/)
      method_name = $1
      raise CustomErrors::InterfaceNotImplementedError.new("#{klass.class.name} needs to implement '#{method_name}' for interface #{self.name}!")
    end
  end
end
