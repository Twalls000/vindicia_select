class CreditCardControl < Base
  self.table_name = :crdctl
  self.primary_key = [:cmpub, :cmctyp]

  alias_attribute :pub_code,        :cmpub
  alias_attribute :card_type,       :cmctyp
  alias_attribute :division_number, :'cmmer#'

end
