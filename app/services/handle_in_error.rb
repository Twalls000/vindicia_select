class HandleInError
  SSL_ERROR = "SSL_connect SYSCALL returned=5 errno=0 state=SSLv3 read server session ticket A"
  VINDICIA_400_ERROR = /Vindicia code 400: (.+) that has already been processed by CashBox Select/
  INVALID_EXPIRATION_ERROR = "invalid credit card expiration date"
  DUPLICATE_ERROR = "Vindicia code 400: Billing has already been attempted for Transaction ID"

  # Errors that are OK to try to resend
  RETRY_ERRORS = [SSL_ERROR, VINDICIA_400_ERROR]

  # Errors that need to be sent back to Genesys as failed
  FAILURE_ERRORS = [INVALID_EXPIRATION_ERROR]

  # Errors that need to be set as pending
  PENDING_ERRORS = [DUPLICATE_ERROR]

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

      if trans.audit_trails.length > 1 || matches_known_failure_errors?(first_event)
        send_failed_to_genesys trans
      elsif matches_known_retry_errors?(first_event)
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

  def self.matches_known_retry_errors?(event)
    matches_known_errors? event, RETRY_ERRORS
  end

  def self.matches_known_failure_errors?(event)
    matches_known_errors? event, FAILURE_ERRORS
  end

  def self.matches_known_pending_errors?(event)
    matches_known_errors? event, PENDING_ERRORS
  end

  def self.matches_known_errors?(event, errors)
    return false if !event.is_a?(String)
    matches = errors.map do |error|
      event.match error
    end
    !!matches.compact.first # Will return true for a value, or false if nil
  end
end
