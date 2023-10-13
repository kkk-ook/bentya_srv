class AddPriceToCarts < ActiveRecord::Migration[7.0]
  def change
    add_column :carts, :price, :integer
  end
end
