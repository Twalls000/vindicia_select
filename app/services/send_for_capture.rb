class SendForCapture
  #
  # This section of code is to send transactions to Vindicia Select
  #
  def self.process
    begin
      mp = get_next_batch
      submit_send_for_capture_job(mp)  if mp
      mp = get_next_batch
    end until mp.nil?
  end

  def self.get_next_batch
    DeclinedCreditCardTransaction.oldest_unsent.first.try(:market_publication)
  end

  def self.submit_send_for_capture_job(mp)
    # Get the transactions and mark them for processing
    transactions_to_send = DeclinedCreditCardTransaction.oldest_unsent.
        by_gci_unit(mp.gci_unit).by_pub_code(mp.pub_code).
        limit(mp.vindicia_batch_size)
    transactions_to_send.each { |t| t.queue_to_vindicia! }
    Rails.logger.info("SendForCapture put the following on the queue: #{transactions_to_send.map { |t| t.id }.join(",")}\n#{DateTime.now}")
    SendForCaptureJob.perform_later transactions_to_send.map { |t| t.id }
  end

  def self.send_transactions_for_capture(transactions_array)
    begin
      transactions = DeclinedCreditCardTransaction.get_queued_to_send_transactions(transactions_array)
      transactions = set_transactions_as_sending(transactions)
      response = Select.bill_transactions transactions

      if response.is_a?(Array) && response.map(&:class).include?(Vindicia::TransactionValidationResponse) || response.is_a?(Vindicia::TransactionValidationResponse)
        response = [response] if response.is_a?(Vindicia::TransactionValidationResponse)
        transactions.each do |t|
          vtvr = response.select { |r| r.is_a?(Vindicia::TransactionValidationResponse) &&
              r.merchant_transaction_id == t.merchant_transaction_id }.first
          if vtvr
            functions = ->{
              t.audit_trails.build(event: "Vindicia code #{vtvr.code}: #{vtvr.description}")
              t.soap_id = vtvr.soap_id
              t.error_sending_to_vindicia if t.may_error_sending_to_vindicia?
            }
            functions.call
            begin
              t.save
            rescue ActiveRecord::StaleObjectError => e
              t.reload
              functions.call # * See comment below
              t.save if t.sending?
            end
          else
            begin
              t.send_to_vindicia!
            rescue ActiveRecord::StaleObjectError => e
              t.reload
              t.send_to_vindicia! if t.sending?
            end
          end
        end
      elsif response.is_a?(Hash) && response[:soap_id]
        transactions.each do |t|
          functions = ->{
            t.soap_id = response[:soap_id]
            t.send_to_vindicia if t.may_send_to_vindicia?
          }
          functions.call
          begin
            t.save
          rescue ActiveRecord::StaleObjectError => e
            t.reload
            functions.call # * See comment below
            t.save if t.sending?
          end
        end
      else
        transactions.each do |t|
          functions = ->{
            t.audit_trails.build(event: "Failed to send", exception: response)
            t.error_sending_to_vindicia if t.may_error_sending_to_vindicia?
          }
          functions.call
          begin
            t.save
          rescue ActiveRecord::StaleObjectError => e
            t.reload
            functions.call # * See comment below
            t.save if t.sending?
          end
        end
      end
    rescue => e
      transactions.each do |trans|
        trans.audit_trails.build(event: e.message, exception: "#{e.class} #{e.message}:\n#{e.backtrace}")
        trans.sending_to_vindicia if trans.may_sending_to_vindicia?
        trans.error_sending_to_vindicia
        trans.save
      end
    end
  end

  def self.set_transactions_as_sending(transactions)
    transactions.map do |t|
      begin
        t.sending_to_vindicia!
        t
      rescue ActiveRecord::StaleObjectError => e
        t.reload
        if t.entry?
          t.sending_to_vindicia!
          t
        else
          nil
        end
      end
    end.compact
  end
end

# * When we get a ActiveRecord::StaleObjectError, the object is reloaded and we
# attempt to save as long as it is in sending status. When the object is
# reloaded, all of the changes we make (like with soap_id or status) get lost so
# we need to make those changes again before we attempt to save again
