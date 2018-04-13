module Vindicia
  class Base
    def self.client_resource
      puts "THIS IS WORKING"
      @client_resource ||= Savon.client(wsdl: self.wsdl,
                                        endpoint: self.endpoint,
                                        namespace: self.namespace,
                                        ssl_verify_mode: :none)
    end

    def self.client_resource_model(class_name)
      local_wsdl = self.model_wsdl(class_name)
      @client_resource ||= Savon.client(wsdl: local_wsdl,
                                        endpoint: self.endpoint,
                                        namespace: self.namespace,
                                        ssl_verify_mode: :none)
    end
  end
end
