class RemoveCountFromCarts < ActiveRecord::Migration[7.0]
  def change
    remove_column :carts, :count, :integer
    remove_column :carts, :delivery_day, :data
  end
end
