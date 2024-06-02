class AddUniqueConstraints < ActiveRecord::Migration[5.2]
  def change
    add_index :cities, :name, unique: true
    add_index :services, :name, unique: true
    add_index :buses, :number, unique: true
  end
end
