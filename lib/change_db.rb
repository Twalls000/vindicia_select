module ChangeDb
  module ClassMethods
    def on_db(gci_unit)
      begin
        con = GenesysConnection.find_by_unit(gci_unit).configuration
        raise RuntimeError, 'No Connection Available' unless con
        self.establish_connection(con)
        @gci_unit = gci_unit
      end
      self
    end

    attr_reader :gci_unit
  end

  module InstanceMethods
    delegate :gci_unit, to: 'self.class'
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
