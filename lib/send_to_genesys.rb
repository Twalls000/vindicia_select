require 'active_support/concern'

module SendToGenesys
  extend ActiveSupport::Concern

  class_methods do

    def send_transaction(transaction)
      update_genesys_record(transaction)
    end

    def get_genesys_record_by_merchant_transaction_id(merchant_transaction_id)
      self.where(vstrid: merchant_transaction_id)
    end

    def update_genesys_record(transaction)
      card = get_genesys_record_by_merchant_transaction_id(transaction.merchant_transaction_id)
      card.vsaust = transaction.charge_status
      card.vsvord = transaction.select_transaction_id
      card.save
    end
  end

  included do
    def save
      new_trans = GenericTransaction.write_to_genesys(self)
    end
  end
end
