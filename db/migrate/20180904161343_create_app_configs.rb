class CreateAppConfigs < ActiveRecord::Migration
  def change
    create_table :app_configs do |t|
      t.string :key
      t.text :value

      t.timestamps null: false
    end
    add_index :app_configs, :key
  end
end
