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
    resp = Vindicia::Connection.call("Select",method_name.to_sym,params)

    response_handler resp, (method_name == :bill_transactions ? true : [])
  end

  def self.date_to_vindicia(date)
    date.strftime("%Y-%m-%dT%H:%M:%S%:z")
  end

  def self.convert_gci_cc_expiration_date_to_vindicia(gci_date)
    Date.strptime(gci_date.to_s.rjust(4,'0'), '%m%y').strftime('%Y%m')
  end

  def self.response_handler(response, default_return = true)
    case response
    when String && /http/
      return default_return
    when Hash, Savon::Response
      return_val =
        if response.is_a? Hash
          response.first[1][:return]
        else
          response.hash[:envelope][:body].first[1][:return]
        end
      raise("Error with soap_id #{return_val[:soap_id]} (code #{return_val[:return_code]}): #{return_val[:return_string]}")
    when Vindicia::TransactionValidationResponse
      trans_id = response.merchant_transaction_id
      code = response.code
      desc = response.description
      raise "Error with merchant_transaction_id #{trans_id} (code #{code}): #{desc}"
    else
      return response
    end
  end
end
