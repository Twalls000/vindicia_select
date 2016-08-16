class DbLoader
  attr_accessor :gci_unit

  DB_PREFIX = Rails.env.production? ? "g" : "q"

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
    slice_size = DB_PREFIX.length
    ActiveRecord::Base.configurations.keys.each do |ar|
      if ar[0,slice_size] == DB_PREFIX
        our_connections[ar[slice_size,ar.length]] = "#{DB_PREFIX + ar[slice_size,ar.length]}"
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
        self.establish_connection(con)
        @gci_unit = gci_unit
      end
      self
    end

    attr_reader :gci_unit

    # def on_db(connection)
    #   self.establish_connection(connection)
    #   self
    # end
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
