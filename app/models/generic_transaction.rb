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

  ### Create transaction to support each site ###
  def self.write_to_genesys(model, type = :update)
    now = Time.now
    tran = GenericTransaction.new
    tran.gci_unit = model.gci_unit
    tran.transaction_number = 0
    tran.sequence_number = HOSTING_LOCATION
    tran.function_type = FUNCTION_TYPE
    tran.function_data = generate_sql(model, type)
    tran.character_coding = ' '
    tran.ascii_delimiter = ' '
    tran.last_changed_on = now.strftime("%Y%m%d")
    tran.last_changed_at = now.strftime("%H%M%S")
    result = tran.save

  end

  def self.get_circ_database(gci_unit)
    GenericTransaction.find_by_sql("select gecirc from c_erls where gciunt=#{ gci_unit }").first.try(:gecirc)
  end

  # Why is this hard coded?
  # Simply put, we are supporting 1 model w/1 possible SQL statement.
  # If that changes then make this class inheritable and this code dynamic.
  def self.generate_sql(model, type = :update)
    case type
    when :update
      "UPDATE crfile.ccvc SET VSAUST = '#{ model.charge_status }', " +
      "VSVORD = '#{ model.select_transaction_id }' " +
      "WHERE VSPPUB = '#{ model.pub_code }' and VSBTCH = '#{ model.batch_id }' and " +
      "VSBDAT = #{ model.batch_date } and VSPACT = #{ model.account_number }"
    when :insert
      "INSERT INTO crfile.ccvc (VSBTCH,VSDAT,VSSTS,VSAUST,VSVORD) " +
      "VALUES ('#{ model.batch_id }',#{ model.batch_date },''," +
      "'#{ model.charge_status }','#{ model.select_transaction_id }')"
    end
  end
end
