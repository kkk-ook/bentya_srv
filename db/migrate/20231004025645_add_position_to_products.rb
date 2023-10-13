class AddPositionToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :position, :integer
  end
end
