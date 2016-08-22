class DbLoader
  # We assume all connections are defined to connect to the many 
  # Genesys databases. 
  # Use the database.yml entry of 1 character + GCI Unit.
  # ie.: if the database is Q9999FILES then use q9999.
  # ie.: if the database is G1532FILES then use g1532.

  attr_accessor :gci_unit

  CONNECTIONS = {}

  def initialize(gci_unit=nil)
    @gci_unit = gci_unit
  end

  def connection
    con = CONNECTIONS[@gci_unit]
    raise RuntimeError, 'No Connection Available'  unless con
    con
  end

  def self.load_genesys_connection_names
    our_connections = {}
    ActiveRecord::Base.configurations.keys.each do |ar|
      if ar.size==5 && ar[1,4].to_i > 1000 # Every GCI Unit is 1000 or greater
        our_connections[ar[1,4]] = ar
      end
    end

    self::CONNECTIONS.merge!(our_connections)
  end

end

module ChangeDb
  module ClassMethods
    def on_db(gci_unit)
      begin
        con = DbLoader.new(gci_unit).connection
        self.establish_connection(con.to_sym)
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

DbLoader.load_genesys_connection_names
