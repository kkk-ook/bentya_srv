class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :user, foreign_key: true, comment: "ユーザーID"
      t.references :product, foreign_key: true, comment: "商品ID"
      t.references :client_product_setting, foreign_key: true, comment: "顧客別商品設定ID"
      t.string :product_name, comment: "商品名"
      t.integer :order_count, comment: "注文商品数"
      t.integer :total_price, comment: "合計金額"
      t.string :stripe_payment_intent_id, comment: "Stripe PaymentIntentID"

      t.datetime :discarded_at, precision: 6
      t.timestamps
    end
  end
end
