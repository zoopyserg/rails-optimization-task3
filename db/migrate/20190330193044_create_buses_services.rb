class CreateBusesServices < ActiveRecord::Migration[5.2]
  def change
    create_table :buses_services do |t|
      t.integer :bus_id
      t.integer :service_id
    end

    add_index :buses_services, :bus_id
    add_index :buses_services, :service_id
  end
end
