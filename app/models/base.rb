require "db_loader"
class Base < ActiveRecord::Base
  self.abstract_class = true

  include ChangeDb
    
  def self.base_search(gci_unit, params={}, select=nil, joins=nil, order = nil, limit=nil)
    self.on_db(gci_unit).select(select).where(params).joins(joins).order(order).limit(limit)
  end
end
