class AddExceptionToAuditTrails < ActiveRecord::Migration
  def change
    add_column :audit_trails, :exception, :text
  end
end
