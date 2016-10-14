class Select
  def self.bill_transactions(transactions)
   call(:bill_transactions, { transactions: Array(transactions).map(&:vindicia_fields) })
 end

  def self.fetch_billing_results(timestamp, end_timestamp = nil, page = 0, page_size = 50)
    end_timestamp = date_to_vindicia(end_timestamp) if end_timestamp
    call(:fetch_billing_results, { timestamp: date_to_vindicia(timestamp), end_timestamp: end_timestamp, page: page, page_size: page_size })
  end

  def self.call(method_name, params = {})
    response_handler Vindicia::Connection.call("Select", method_name.to_sym, params),
    (method_name == :bill_transactions ? true : [])
  end

  def self.date_to_vindicia(date)
    date.strftime("%Y-%m-%dT%H:%M:%S%:z")
  end

  def self.convert_gci_cc_expiration_date_to_vindicia(gci_date)
    gci_date.strftime('%Y%m')
  end

  def self.response_handler(response, default_return = true)
    case response
    when Hash
      return response
    when Savon::Response
      return_val = response.hash[:envelope][:body].first[1][:return]
      raise("Error with soap_id #{return_val[:soap_id]} (code #{return_val[:return_code]}): #{return_val[:return_string]}")
    when Vindicia::Transaction
      Array(response)
    else
      response
    end
  end
end
