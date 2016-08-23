class CreditCard < Base
  self.table_name = :ccrd
  self.primary_key = [:pub, :actnbr]

  alias_attribute :pub_code,        :pub
  alias_attribute :account_number,  :actnbr
  alias_attribute :card_number,     :crdnbr
  alias_attribute :card_type,       :ccctyp
  alias_attribute :expiration_date, :cccexd
  alias_attribute :name,            :ccname
  alias_attribute :address_line1,   :ccadr1
  alias_attribute :address_line2,   :ccadr2
  alias_attribute :city_state,      :ccctst
  alias_attribute :zip_code,        :pozip5

  belongs_to :declined_credit_card, foreign_key: [:pub, :actnbr], primary_key: [:prspub, :prpact]

  def self.summary(gci_unit)
    self.on_db(gci_unit).select("ccrd.*").joins(:declined_credit_card)
  end

end
