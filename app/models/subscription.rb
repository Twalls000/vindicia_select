class Subscription < Base
  self.table_name = :subscrip
  self.primary_key = [:hspub, :'hsact#']

end
