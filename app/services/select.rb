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

    # if resp.is_a?(String) && resp.match(/http/)
    #   return []
    # end
    resp
  end

  def self.date_to_vindicia(date)
    date.strftime("%Y-%m-%dT%H:%M:%S%:z")
  end

  def self.convert_gci_cc_expiration_date_to_vindicia(gci_date)
    Date.strptime(gci_date.to_s.rjust(4,'0'), '%m%y').strftime('%Y%m')
  end
end
