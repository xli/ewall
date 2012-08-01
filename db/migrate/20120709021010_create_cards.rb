class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :image
      t.integer :number
      t.integer :x
      t.integer :y
      t.integer :width
      t.integer :height
      t.references :snapshot
      t.boolean :positive

      t.timestamps
    end
    add_index :cards, :snapshot_id
  end
end
