class AuditTrail < ActiveRecord::Base
  serialize :changed_values
  serialize :exception
  belongs_to :declined_credit_card_transaction
end
