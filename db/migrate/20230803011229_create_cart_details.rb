class CreateCartDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :cart_details do |t|
      t.references :cart, foreign_key: true, null: true, comment: "カートID"
      t.integer :count, comment: "個数"
      t.date :delivery_day, comment: "配送日"

      t.timestamps
    end
  end
end
