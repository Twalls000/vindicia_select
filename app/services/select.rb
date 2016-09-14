class Select
  def self.bill_transactions(transactions)
    transactions = Array(transactions)

    param_transactions = transactions.map(&:vindicia_fields)

    call(:bill_transactions, { transactions: param_transactions })
  end

  def self.call(method_name, params = {})
    resp = Vindicia::Connection.call("Select",method_name.to_sym,params)

    # if resp.is_a?(String) && resp.match(/http/)
    #   return []
    # end
    resp
  end
end
