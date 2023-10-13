class CreateProductImages < ActiveRecord::Migration[7.0]
  def change
    create_table :product_images do |t|
      t.references :product, foreign_key: true, comment: "商品ID"
      t.string :image, comment: "写真"

      t.datetime :discarded_at, precision: 6
      t.timestamps
    end
  end
end
