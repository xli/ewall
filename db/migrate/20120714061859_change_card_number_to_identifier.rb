class ChangeCardNumberToIdentifier < ActiveRecord::Migration
  def change
    rename_column :cards, :number, :identifier
    change_column :cards, :identifier, :string
  end
end
