require 'test_helper'

class AuditTrailTest < ActiveSupport::TestCase
  def setup
    @audit_trail = audit_trails(:one)
  end

  class Validations < AuditTrailTest
    test "the audit trail should have an event" do
      assert_not_nil @audit_trail.event
    end

    test "the audit trail should have a transaction" do
      assert_not_nil @audit_trail.declined_credit_card_transaction
    end

    test "the audit trail should have changed values if there are any" do

    end
  end
end
