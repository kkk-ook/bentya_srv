class RenameCartAddedAtColumnToCarts < ActiveRecord::Migration[7.0]
  def change
    rename_column :carts, :cart_added_at, :delivery_day
  end
end
