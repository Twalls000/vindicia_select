class DeclinedCreditCard < Base
  self.table_name = "ccdc".to_sym

  alias_attribute :pub_code,        :prspub
  alias_attribute :batch_id,        :prbtch
  alias_attribute :batch_date,      :prbdat
  alias_attribute :account_number,  :prpact
  alias_attribute :credit_amount,   :prcamt
  alias_attribute :debit_amount,    :prdamt
  alias_attribute :decline_status,  :prnsts
  alias_attribute :decline_reson,   :prndcr

  # attribute_names, 
  def method_name
  end
end
