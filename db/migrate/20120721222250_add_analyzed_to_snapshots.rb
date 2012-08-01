class AddAnalyzedToSnapshots < ActiveRecord::Migration
  def change
    add_column :snapshots, :in_analysis, :integer
  end
end
