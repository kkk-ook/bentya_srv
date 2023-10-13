class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.references :category, foreign_key: true, comment: "カテゴリID"
      t.string :name, comment: "商品名"
      t.string :abbreviated_name, comment: "商品名の略語"
      t.string :catch_phrase, comment: "キャッチフレーズ"
      t.integer :display_price, comment: "表示価格"
      t.integer :common_selling_price, comment: "共通販売価格"
      t.boolean :is_public, comment: "表示・非表示"
      t.boolean :is_same_day_reservation, comment: "当日予約"
      t.date :period_start_on, comment: "期間限定開始日"
      t.date :period_end_on, comment: "期間限定終了日"
      t.string :description, comment: "商品説明"
      t.string :notes, comment: "注釈"

      t.datetime :discarded_at, precision: 6
      t.timestamps
    end
  end
end
