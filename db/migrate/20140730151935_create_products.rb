class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name, limit: 30
      t.string :image_path, limit: 100
      t.float :price
      t.float :rating
      t.integer :venue_id

      t.timestamps
    end
    add_index :products,:venue_id
  end
end
