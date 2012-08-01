class CreateColumnHeads < ActiveRecord::Migration
  def change
    create_table :column_heads do |t|
      t.string :title
      t.integer :position
      t.references :wall

      t.timestamps
    end
    add_index :column_heads, :wall_id
  end
end
