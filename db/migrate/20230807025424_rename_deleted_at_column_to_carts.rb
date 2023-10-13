class RenameDeletedAtColumnToCarts < ActiveRecord::Migration[7.0]
  def change
    rename_column :carts, :deleted_at, :discarded_at
  end
end
