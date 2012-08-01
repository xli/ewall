class DropColumnHeadsTable < ActiveRecord::Migration
  def change
    drop_table :column_heads
  end
end
