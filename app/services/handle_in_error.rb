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

    transactions.each do |trans|
      if trans.audit_trails.length > 1
        # Mark as failed and send to Genesys
      elsif trans.audit_trails.first.event == SSL_ERROR_MESSAGE ||
            trans.audit_trails.first.event =~ VINDICIA_400_MESSAGE
        # Move back to entry status to be picked up again
      else
        # Mark as failed and send to Genesys, also log a Datadog event
      end
    end
  end
end
