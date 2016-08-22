class DeclinedCreditCard < Base
  self.table_name = :ccdc
  self.primary_key = [:batch_id, :account_number]

  alias_attribute :pub_code,        :prspub
  alias_attribute :batch_id,        :prbtch
  alias_attribute :batch_date,      :prbdat
  alias_attribute :account_number,  :prpact
  alias_attribute :credit_amount,   :prcamt
  alias_attribute :debit_amount,    :prdamt
  alias_attribute :decline_status,  :prnsts
  alias_attribute :decline_reson,   :prndcr

  belongs_to :subscription, foreign_key: [:prspub, :prpact]

  # attribute_names
  def self.summary(gci_unit)
    self.on_db(gci_unit).select("ccdc.*, subscrip.hsper# ").joins(:subscription)
  end
end
