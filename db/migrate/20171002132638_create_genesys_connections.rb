class CreateGenesysConnections < ActiveRecord::Migration
  def change
    create_table :genesys_connections do |t|
      t.integer :gci_unit, null: false
      t.string  :schema
      t.string  :adapter
      t.string  :datasource
      t.string  :username
      t.string  :password

      t.timestamps null: false
    end
    add_index :genesys_connections, [:gci_unit, :schema], unique: true

    ActiveRecord::Base.configurations.select do |name,configurations|
      name.match /(g|q)\d{4}/
    end.each do |gci_unit, configurations|
      say_with_time "Adding #{ gci_unit } connection" do
        GenesysConnection.create(gci_unit: gci_unit.gsub(/(g|q)/, "").to_i,
                                 schema: configurations['schema'])
      end
    end
  end
end
