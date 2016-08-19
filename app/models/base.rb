require "db_loader"
class Base < ActiveRecord::Base
  self.abstract_class = true

  include ChangeDb
    
  def self.base_search(gci_unit, params={}, order = nil, limit=nil)
    self.on_db(gci_unit).where(params).order(order).limit(limit)
  end
end
