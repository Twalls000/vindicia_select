class CreditCard < Base
  self.table_name = :ccrd
  self.primary_key = [:pub, :actnbr]

  alias_attribute :pub_code,        :pub

  belongs_to :declined_credit_card, foreign_key: [:pub, :actnbr], primary_key: [:prspub, :prpact]

  def self.summary(gci_unit)
    self.on_db(gci_unit).select("ccrd.*").joins(:declined_credit_card)
  end

end
