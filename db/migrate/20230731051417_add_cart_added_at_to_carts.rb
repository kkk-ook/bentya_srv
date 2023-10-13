class AddCartAddedAtToCarts < ActiveRecord::Migration[7.0]
  def change
    add_column :carts, :cart_added_at, :datetime
  end
end
