class AddSaltToWalls < ActiveRecord::Migration
  def change
    add_column :walls, :salt, :string
    Wall.reset_column_information
    Wall.all.each{|w| w.update_attribute(:salt, SecureRandom.hex)}
  end
end
