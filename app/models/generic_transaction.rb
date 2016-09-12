class GenericTransaction < ActiveRecord::Base
  # This file is special. It does not use a sequence for key assignment.
  # The db2odbc_adapter.rb has a special exception for "generic_transactions"
  # so be careful before changing the following table name.

  self.table_name = 'v_generic_transactions'
  self.establish_connection :ods_library

  validates_presence_of :function_type, :function_data
  validates_numericality_of :transaction_number, :sequence_number,
                            :last_changed_on, :last_changed_at
  validates_inclusion_of :character_coding, :in => ['', ' ', 'A', 'E']

  def self.last_serial_number_for_unit(gci_unit)
    where('gci_unit = ?', gci_unit).select("max(id) as serial_number")[0].serial_number rescue nil
  end

  def self.last_transaction_time_for_unit(gci_unit)
    serial_number = last_serial_number_for_unit(gci_unit)
    if serial_number
      entry = where(['gci_unit = ? and id = ?', gci_unit,
            serial_number]).select('last_changed_on, last_changed_at').first
      entry.transaction_time
    else
      nil
    end
  end

  ### Instance Methods ###

  def transaction_time
    date = last_changed_on
    time = last_changed_at
    begin
      Time.local(date / 10000, date / 100 % 100, date % 100,
          time / 10000, time / 100 % 100, time % 100)
    rescue
      nil
    end
  end
end
