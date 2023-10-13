class CreateOrderHeaders < ActiveRecord::Migration[7.0]
  def change
    create_table :order_headers do |t|
      t.references :user, foreign_key: true, comment: "ユーザーID"
      t.integer :total_count, comment: "注文商品数"
      t.integer :total_price, comment: "合計金額"
      t.string :stripe_payment_intent_id, comment: "Stripe PaymentIntentID"

      t.timestamps
    end
  end
end
