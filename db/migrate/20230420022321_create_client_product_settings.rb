class CreateClientProductSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :client_product_settings do |t|
      t.references :product, foreign_key: true, comment: "商品ID"
      t.references :client, foreign_key: true, comment: "顧客ID"
      t.integer :price, comment: "顧客別販売価格"
      t.boolean :is_public, comment: "表示・非表示"

      t.datetime :discarded_at, precision: 6
      t.timestamps
    end
  end
end
