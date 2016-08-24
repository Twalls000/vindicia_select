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
  # These aliases are for the Credit Card model
  alias_attribute :card_number,     :crdnbr
  alias_attribute :card_type,       :ccctyp
  alias_attribute :expiration_date, :cccexd
  alias_attribute :name,            :ccname
  alias_attribute :address_line1,   :ccadr1
  alias_attribute :address_line2,   :ccadr2
  alias_attribute :city_state,      :ccctst
  alias_attribute :zip_code,        :pozip5
  # This alias is for the Subscription model
  alias_attribute :customer_id,     :'hsper#'
  # This alias is for the Card Control model
  alias_attribute :division_number, :'cmmer#'

  belongs_to :subscription, foreign_key: [:prspub, :prpact]
  belongs_to :credit_card, foreign_key: [:prspub, :prpact]

  # attribute_names
  def self.summary(gci_unit, pub_code)
    self.on_db(gci_unit).where({ pub_code: pub_code }).
      select("#{gci_unit}, ccdc.*, subscrip.hsper#, ccrd.*, crdctl.*, crdctl.cmmer# as division_number ").
      joins(:subscription, :credit_card,
        " INNER JOIN crdctl ON crdctl.cmpub = '#{ pub_code }' and crdctl.cmctyp = ccrd.ccctyp")
  end

  def declined_timestamp
    Time.strptime("#{audit_date} #{audit_time.to_s.rjust(6, '0')}", "%Y%m%d %H%M%S")  rescue nil
  end

  def merchant_transaction_id
    "#{ gci_unit }-#{ prspub }-#{ prbtch }-#{ prbdat }-#{ prpact }"
  end
end
