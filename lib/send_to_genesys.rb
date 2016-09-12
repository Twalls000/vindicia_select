require 'active_support/concern'

module SendToGenesys
  extend ActiveSupport::Concern

  class_methods do

    def send_transaction(transaction)
      # transaction gets passed in and sent to Genesys
    end

    def chargeback_success?(transaction)
      # determine if transaction is set to print
    end

    def set_as_successful(transaction)
      # send transaction details to Genesys
    end

    def set_to_printed_bill(transaction)
      # notify Genesys that the account should be set to printed bill
    end

  end

end
