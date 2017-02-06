class AddSoapIdToAuditTrails < ActiveRecord::Migration
  def change
    add_column :audit_trails, :soap_id, :string
  end
end
