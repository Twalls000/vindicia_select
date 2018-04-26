require 'test_helper'

class GenesysConnectionTest < ActiveSupport::TestCase
  def setup
    @genesys_connection  = genesys_connections :one
    @genesys_connection2 = genesys_connections :two
    @defaults = GenesysConnection::DEFAULTS
  end

  class Validations < GenesysConnectionTest
    test "gci_unit uniqueness" do
      existing_unit = @genesys_connection.gci_unit
      refute GenesysConnection.new(gci_unit: existing_unit).valid?
    end
  end

  class Defaults < GenesysConnectionTest
    test "a method is defined for each default that returns the column value or default" do
      @defaults.keys.each do |column|
        assert GenesysConnection.new.respond_to? column.to_sym
      end

      assert_equal @defaults['datasource'], @genesys_connection.datasource
      refute_equal @defaults['datasource'], @genesys_connection2.datasource
    end
  end

  class SelfFindByUnit < GenesysConnectionTest
    test "finds GenesysConnection based on unit number" do
      existing_unit = @genesys_connection.gci_unit

      assert_equal @genesys_connection, GenesysConnection.find_by_unit(existing_unit)
    end
  end

  class Configuration < GenesysConnectionTest


    test "returns defaults and column values, not id, gci_unit, created_at, or updated_at" do
      expected = @genesys_connection.attributes.except('id','gci_unit','created_at','updated_at').reject { |k,v| v.nil? }
      expected = @defaults.merge expected
      assert_equal expected, @genesys_connection.configuration

      expected = @genesys_connection2.attributes.except('id','gci_unit','created_at','updated_at').reject { |k,v| v.nil? }
      expected = @defaults.merge expected
      assert_equal expected, @genesys_connection2.configuration
    end

    test "column values override defaults" do
      assert_equal @defaults['datasource'], @genesys_connection.configuration['datasource']
      refute_equal @defaults['datasource'], @genesys_connection2.configuration['datasource']
    end
  end
end
