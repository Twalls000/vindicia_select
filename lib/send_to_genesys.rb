require 'active_support/concern'

module SendToGenesys
  extend ActiveSupport::Concern

  class_methods do

    def send_transaction(transaction)
      GenericTransaction.write_to_genesys(transaction)
    end
  end
end
