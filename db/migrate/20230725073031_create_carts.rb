class CreateCarts < ActiveRecord::Migration[7.0]
  def change
    create_table :carts do |t|
      t.references :user, foreign_key: true, null: true, comment: "ユーザーID"
      t.references :product, foreign_key: true, null: true, comment: "商品ID"
      t.integer :count, comment: "個数"
      t.string :note, comment: "備考"

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
