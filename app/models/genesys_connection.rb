class GenesysConnection < ActiveRecord::Base
  DEFAULTS = ActiveRecord::Base.configurations["#{ Rails.env }_defaults"]

  validates :gci_unit, uniqueness: true

  # Adding methods for each of the default configurations. Uses the default
  # unless there is a value in the table.
  DEFAULTS.each do |attr_name,value|
    define_method(attr_name.to_sym) do
      super() || value
    end
  end

  def self.find_by_unit(unit)
    find_by gci_unit: unit.to_i
  end

  def configuration
    attrs = attributes.except("id","gci_unit","created_at","updated_at").reject { |k,v| v.blank? }
    DEFAULTS.merge attrs
  end
end
