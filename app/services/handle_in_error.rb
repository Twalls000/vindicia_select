class HandleInError
  SSL_ERROR = "SSL_connect SYSCALL returned=5 errno=0 state=SSLv3 read server session ticket A"
  VINDICIA_400_ALREADY_PROCESSED_ERROR = /Vindicia code 400: (.+) that has already been processed by CashBox Select/
  VINDICIA_400_ALREADY_PROCESSING_ERROR = /Vindicia code 400: Failed to schedule billing attempts: (.+) that is currently being processed by CashBox Select/
  INVALID_EXPIRATION_ERROR = "invalid credit card expiration date"
  DUPLICATE_ERROR = "Vindicia code 400: Billing has already been attempted for Transaction ID"

  # Errors that are OK to try to resend
  RETRY_IMMEDIATELY_ERRORS = [SSL_ERROR, VINDICIA_400_ALREADY_PROCESSED_ERROR]
  RETRY_AFTER_10_DAYS_ERRORS = [VINDICIA_400_ALREADY_PROCESSING_ERROR]

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
      event = trans.failure_audit_trails.last.try(:event)

      if matches_known_pending_errors?(event)
        trans.status = "pending"
        trans.save
      elsif trans.failure_audit_trails.length > 1 || matches_known_failure_errors?(event)
        send_failed_to_genesys trans
      elsif matches_known_retry_immediately_errors?(event)
        transaction.queue_for_send!
      elsif matches_known_retry_after_10_days_errors?(event)
        QueueTransactionForSendForCaptureJob.set(wait: 10.days).perform_later(transaction)
      else
        send_failed_to_genesys trans
        events = trans.failure_audit_trails.map(&:event)
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

  def self.matches_known_retry_immediately_errors?(event)
    matches_known_errors? event, RETRY_IMMEDIATELY_ERRORS
  end

  def self.matches_known_retry_after_10_days_errors?(event)
    matches_known_errors? event, RETRY_AFTER_10_DAYS_ERRORS
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
