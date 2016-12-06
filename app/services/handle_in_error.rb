class HandleInError
  SSL_ERROR_MESSAGE = "SSL_connect SYSCALL returned=5 errno=0 state=SSLv3 read server session ticket A"
  VINDICIA_400_MESSAGE = /Vindicia code 400: (.+) that has already been processed by CashBox Select/

  def self.process
    DeclinedCreditCardTransaction.in_error.each_slice(10) do |slice|
      HandleInErrorJob.perform_later(slice.map(&:id))
    end
  end

  def self.handle(ids)
    transactions = DeclinedCreditCardTransaction.find(ids)
    transactions.select!(&:in_error?)

    transactions.each do |trans|
      first_event = trans.audit_trails.first.try(:event)

      if trans.audit_trails.length > 1
        send_failed_to_genesys trans
      elsif first_event == SSL_ERROR_MESSAGE ||
            first_event =~ VINDICIA_400_MESSAGE
        trans.status = "entry"
        trans.save
      else
        send_failed_to_genesys trans
        events = trans.audit_trails.map(&:event)
        message = events.empty? ? "Transaction had no audit trails" : events.join("\n")

        DataDog.send_event(
          "Transaction with ID #{trans.id}:\n\n#{message}",
          "Encountered unknown error when handling in_error transaction",
          "error",
          ["handle_in_error"]
        )
      end
    end
  end

  private

  def self.send_failed_to_genesys(transaction)
    transaction.handle_error
    transaction.failed_to_send_to_genesys unless DeclinedCreditCard.send_transaction(transaction)
    transaction.save
  end
end
