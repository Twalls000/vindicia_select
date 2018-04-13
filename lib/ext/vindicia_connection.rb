module Vindicia::Connection
  def self.client_resource_model(class_name)
    puts "THIS IS WORKING CONNECTION"
    local_wsdl = "#{Rails.root}/config/wsdl/#{class_name}.wsdl" rescue ""
    local_wsdl = self.model_wsdl(class_name) unless !local_wsdl.blank? && File.exists?(local_wsdl)
    @client_resource_model = Savon.client(wsdl: local_wsdl,
        endpoint: self.endpoint,
        namespace: self.namespace,
        open_timeout: self.open_timeout,
        read_timeout: self.read_timeout,
        ssl_cert_file: VINDICIA_CERT_FILE,
        ssl_ca_cert_file: VINDICIA_CERT_FILE)
    @client_resource_model
  end

  def self.response_handler(class_name,response, action)
    return_code = response.body["#{action}_response".to_sym][:return][:return_code]
    return_string = response.body["#{action}_response".to_sym][:return][:return_string]

    if (response.success? && return_code == "200")
      if class_name == "Vindicia::Select" && action == :bill_transactions && !response.body["#{action}_response".to_sym][:response]
        return {return_code: return_code, soap_id: response.body["#{action}_response".to_sym][:return][:soap_id]}
      elsif class_name == "Vindicia::Select" && action == :fetch_billing_results && !response.body["#{action}_response".to_sym][:transactions]
        return {return_code: return_code, soap_id: response.body["#{action}_response".to_sym][:return][:soap_id]}
      else
        res = response.body["#{action}_response".to_sym][response.body["#{action}_response".to_sym].keys[1]]
        soap_id = response.body["#{action}_response".to_sym][:return][:soap_id]

        if res.is_a? Hash
          res[:soap_id] = soap_id
        elsif res.is_a? Array
          res.each { |t| t[:soap_id] = soap_id }
        end

        res
      end
    else
      Rails.logger.error("Response #{ response.class }")
      Rails.logger.error("Response #{ response.inspect }")
      return response
    end

    if res.is_a?(Hash)
      "Vindicia::#{self.response_class_name(res)}".constantize.new(res)
    elsif res.is_a?(Array)
      res.map { |x| "Vindicia::#{self.response_class_name(x)}".constantize.new(x) }
    else
      res
    end
  end
end
