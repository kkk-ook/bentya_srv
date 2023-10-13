class CreateProductDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :product_details do |t|
      t.references :product, foreign_key: true, comment: "商品ID"
      t.date :inventory_date, comment: "日付"
      t.integer :count, comment: "注文可能数"

      t.timestamps
    end
  end
end
