class AddPasswordToWalls < ActiveRecord::Migration
  def change
    add_column :walls, :password, :string
  end
end
