class CreateSnapshots < ActiveRecord::Migration
  def change
    create_table :snapshots do |t|
      t.string :image
      t.timestamp :taken_at
      t.references :wall

      t.timestamps
    end
    add_index :snapshots, :wall_id
  end
end
