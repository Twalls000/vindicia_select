module Vindicia
  class Base
    def self.client_resource
      puts "THIS IS WORKING"
      @client_resource ||= Savon.client(wsdl: self.wsdl,
                                        endpoint: self.endpoint,
                                        namespace: self.namespace,
                                        ssl_cert_file: VINDICIA_CERT_FILE,
                                        ssl_ca_cert_file: VINDICIA_CERT_FILE)
    end

    def self.client_resource_model(class_name)
      local_wsdl = self.model_wsdl(class_name)
      @client_resource ||= Savon.client(wsdl: local_wsdl,
                                        endpoint: self.endpoint,
                                        namespace: self.namespace,
                                        ssl_cert_file: VINDICIA_CERT_FILE,
                                        ssl_ca_cert_file: VINDICIA_CERT_FILE)
    end
  end
end
