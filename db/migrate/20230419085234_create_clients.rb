class CreateClients < ActiveRecord::Migration[7.0]
  def change
    create_table :clients do |t|
      t.string :code, comment: "顧客コード"
      t.string :name, comment: "顧客名"
      t.string :company_name, comment: "会社名"
      t.string :postal_code, comment: "郵便番号"
      t.integer :prefecture, comment: "都道府県"
      t.string :address1, comment: "市区町村・番地"
      t.string :address2, comment: "建物名・部屋番号"
      t.string :tel, comment: "電話番号"
      t.string :staff_1, comment: "担当者1"
      t.string :staff_2, comment: "担当者2"
      t.string :staff_3, comment: "担当者3"
      t.string :memo, comment: "メモ"
      
      t.datetime :discarded_at, precision: 6
      t.timestamps
    end
  end
end
