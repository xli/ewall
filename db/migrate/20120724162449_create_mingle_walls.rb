class CreateMingleWalls < ActiveRecord::Migration
  def change
    create_table :mingle_walls do |t|
      t.text :url
      t.references :wall
      t.string :login
      t.string :password

      t.timestamps
    end
    add_index :mingle_walls, :wall_id
  end
end
