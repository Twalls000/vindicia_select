class AuditTrail < ActiveRecord::Base
  serialize :changed_values
  belongs_to :declined_credit_card_transaction
end
