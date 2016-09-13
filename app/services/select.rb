class Select
  def self.bill_transactions(transactions)
    transactions = Array(transactions)

    param_transactions = transactions.map do |trans|
      # TODO: remove the following lines when tokens supported by Vindicia
      trans.payment_method_tokenized = false

      trans.subscription_id = SecureRandom.hex
      attrs = trans.attributes.except('created_at', 'updated_at', 'status')
      attrs['payment_method_id'] = 'CreditCard'
      attrs['status'] = attrs.delete('charge_status')
      attrs['timestamp'] = DateTime.now
      attrs.keys.each { |key| attrs[key.camelize(:lower)] = attrs.delete(key) }

      attrs
    end

    # call(:bill_transactions, { transactions: param_transactions })
  end

  def self.call(method_name, params = {})
    resp = Vindicia::Connection.call("Select",method_name.to_sym,params)

    # if resp.is_a?(String) && resp.match(/http/)
    #   return []
    # end
    resp
  end
end
