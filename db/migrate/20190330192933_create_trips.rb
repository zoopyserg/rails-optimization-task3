class CreateTrips < ActiveRecord::Migration[5.2]
  def change
    create_table :trips do |t|
      t.integer :from_id
      t.integer :to_id
      t.string :start_time
      t.integer :duration_minutes
      t.integer :price_cents
      t.integer :bus_id
    end

    add_index :trips, :from_id
    add_index :trips, :to_id
    add_index :trips, :bus_id
  end
end
