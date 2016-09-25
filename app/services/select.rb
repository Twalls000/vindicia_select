class Select
  def self.bill_transactions(transactions)
    transactions = Array(transactions)

    param_transactions = transactions.map(&:vindicia_fields)
    call(:bill_transactions, { transactions: param_transactions })
  end

  def self.fetch_billing_results(timestamp, end_timestamp = nil, page = 0, page_size = 50)
    timestamp = date_to_vindicia timestamp
    end_timestamp = date_to_vindicia(end_timestamp) if end_timestamp

    call(:fetch_billing_results, { timestamp: timestamp, end_timestamp: end_timestamp, page: page, page_size: page_size })
  end

  def self.call(method_name, params = {})
    binding.pry
    resp = Vindicia::Connection.call("Select", method_name.to_sym, params)
    response_handler resp, (method_name == :bill_transactions ? true : [])
  end

  def self.date_to_vindicia(date)
    date.strftime("%Y-%m-%dT%H:%M:%S%:z")
  end

  def self.convert_gci_cc_expiration_date_to_vindicia(gci_date)
    gci_date.strftime('%Y%m')
  end

  def self.response_handler(response, default_return = true)
    case response
    when String && /http/
      return default_return
    when Savon::Response
      return_val = response.hash[:envelope][:body].first[1][:return]
      raise("Error with soap_id #{return_val[:soap_id]} (code #{return_val[:return_code]}): #{return_val[:return_string]}")
    when Vindicia::Transaction
      return Array(response)
    else
      return response
    end
  end

  private
  def create_vindicia_class(vindicia_class)
    class_name = vindicia_class.name
    attributes = vindicia_class.attributes

    Vindicia.const_set(class_name, Class.new() do
      include ActiveModel::Model
      include ActiveModel::Validations

      self.const_set('ATTRIBUTES',attributes)

      attr_accessor *attributes

      def initialize(attributes={})
        attributes.keys.each do |name|
          is_vindicia_object = attributes[name].is_a?(Hash) && attributes[name][:"@xsi:type"].split(':')[0] =='vin'
          if is_vindicia_object && attributes[name].is_a?(Hash)
            class_name = "Vindicia::#{attributes[name][:"@xsi:type"].split(':')[1]}"
            begin
              send("#{name}=", class_name.constantize.new(attributes[name]))
            rescue
              vindicia_class = Vindicia::Schema.new.classes.select {|class_obj| class_obj.name == class_name.split('::')[1]}.first
              if vindicia_class
                Vindicia::SingleClassBuilder.new vindicia_class
                send("#{name}=", class_name.constantize.new(attributes[name]))
              else
                return gem_original_require(class_name)
              end
            end
          else
            send("#{name}=", attributes[name]) rescue nil
          end

        end
      end

      def attributes
        self.class::ATTRIBUTES.inject({}) do |hash, key|
          hash.merge({ key => self.send(key) })
        end
      end

      def self.class_methods
        Vindicia::Connection.client_resource_model(self.name.split('::').last).operations rescue []
      end

    end)

  end

  def create_vindicia_class_methods(vindicia_class)
    class_name = vindicia_class.name
    class_methods = "Vindicia::#{class_name}".constantize.class_methods rescue []

    "Vindicia::#{class_name}".constantize.send :define_method, :vindicia_methods do
      "Vindicia::#{class_name}".constantize.class_methods rescue []
    end

    class_methods.each do |method_name|
      "Vindicia::#{class_name}".constantize.define_singleton_method(method_name.to_sym) do |params = {}|
        Vindicia::Connection.call("#{class_name}",method_name.to_sym,params)
      end
    end

  end
end
