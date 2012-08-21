class AddTimeZoneToWalls < ActiveRecord::Migration
  def change
    add_column :walls, :time_zone, :string
  end
end
