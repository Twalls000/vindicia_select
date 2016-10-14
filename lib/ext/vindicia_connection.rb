module Vindicia::Connection
  def self.response_handler(class_name,response, action)
      return_code = response.body["#{action}_response".to_sym][:return][:return_code]
      return_string = response.body["#{action}_response".to_sym][:return][:return_string]

      if (response.success? && return_code == "200")
        if class_name == "Vindicia::Select" && action == :bill_transactions && !response.body["#{action}_response".to_sym][:response]
          return {return_code: return_code, soap_id: response.body["#{action}_response".to_sym][:return][:soap_id]}
        elsif class_name == "Vindicia::Select" && action == :fetch_billing_results && !response.body["#{action}_response".to_sym][:transactions]
          return []
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
