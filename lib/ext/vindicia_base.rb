module Vindicia
  class Base
    def self.client_resource
      puts "THIS IS WORKING"
      @client_resource ||= Savon.client(wsdl: self.wsdl,
                                        endpoint: self.endpoint,
                                        namespace: self.namespace,
                                        ssl_cert_file: VINDICIA_CERT_FILE)
    end
  end
end
