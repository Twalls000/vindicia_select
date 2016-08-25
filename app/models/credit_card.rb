class CreditCard < Base
  self.table_name = :ccrd
  self.primary_key = [:pub, :actnbr]

  alias_attribute :pub_code,        :pub

  belongs_to :declined_credit_card, foreign_key: [:pub, :actnbr], primary_key: [:prspub, :prpact]

end
