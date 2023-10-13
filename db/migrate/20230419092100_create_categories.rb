class CreateCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      t.string :name, comment: "カテゴリ名"
      t.string :image, comment: "写真"
      t.string :icon, comment: "アイコン"
      t.string :description, comment: "説明"

      t.datetime :discarded_at, precision: 6
      t.timestamps
    end
  end
end
