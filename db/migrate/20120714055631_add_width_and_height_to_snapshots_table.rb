class AddWidthAndHeightToSnapshotsTable < ActiveRecord::Migration
  def change
    add_column :snapshots, :width, :integer
    add_column :snapshots, :height, :integer
  end
end
