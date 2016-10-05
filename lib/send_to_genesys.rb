require 'active_support/concern'

module SendToGenesys
  extend ActiveSupport::Concern

  class_methods do

    def send_transaction(transaction)
      if chargeback_success?(transaction)
        set_as_successful(transaction)
      else
        set_to_printed_bill(transaction)
      end
    end

    def chargeback_success?(transaction)
      case transaction.charge_status
      when "Captured" then true
      when "BillingNotAttempted", "Cancelled", "Failed", "Refunded" then false
      else
        false # TODO: Mark in error for having unrecognized charge status?
      end
    end

    def set_as_successful(transaction)
      # send transaction details to Genesys
    end

    def set_to_printed_bill(transaction)
      # notify Genesys that the account should be set to printed bill
    end

  end

end
