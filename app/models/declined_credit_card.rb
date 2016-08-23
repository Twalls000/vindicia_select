class DeclinedCreditCard < Base
  self.table_name = :ccdc
  self.primary_key = [:prbtch, :prspub, :prpact]

  alias_attribute :pub_code,        :prspub
  alias_attribute :batch_id,        :prbtch
  alias_attribute :batch_date,      :prbdat
  alias_attribute :account_number,  :prpact
  alias_attribute :amount,          :prcamt
  alias_attribute :debit_amount,    :prdamt
  alias_attribute :decline_status,  :prnsts
  alias_attribute :decline_reason,  :prndcr
  alias_attribute :audit_date,      :udtdat
  alias_attribute :audit_time,      :udttim

  belongs_to :subscription, foreign_key: [:prspub, :prpact]
  belongs_to :credit_card, foreign_key: [:prspub, :prpact]

  # attribute_names
  def self.summary(gci_unit)
    self.on_db(gci_unit).select("ccdc.*, subscrip.hsper# ").joins(:subscription, :credit_card)
  end

  def declined_timestamp
    Time.strptime("#{audit_date} #{audit_time.to_s.rjust(6, '0')}", "%Y%m%d %H%M%S")  rescue nil
  end

  def merchant_transaction_id
    "#{ prspub }-#{ prbtch }-#{ prbdat }-#{ prpact }"
  end
end
