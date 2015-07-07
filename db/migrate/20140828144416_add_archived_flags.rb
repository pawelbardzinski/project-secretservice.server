class AddArchivedFlags < ActiveRecord::Migration
  def up
    add_column :users, :archived, :boolean,default:false
    add_column :products, :archived, :boolean,default:false
    add_column :venues, :archived, :boolean,default:false
  end
  def down
    remove_column :users, :archived
    remove_column :products, :archived
    remove_column :venues, :archived
  end
end
