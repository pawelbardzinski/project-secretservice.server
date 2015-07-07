class RemoveImagePathFromProducts < ActiveRecord::Migration
  def up
    remove_column :products, :image_path
  end
  def down
    add_column :products, :image_path, :string, limit:100
  end
end
