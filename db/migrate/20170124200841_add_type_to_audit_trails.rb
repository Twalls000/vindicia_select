class AddTypeToAuditTrails < ActiveRecord::Migration
  def change
    add_column :audit_trails, :type, :string

    AuditTrail.update_all type: "FailureAuditTrail"
  end
end
