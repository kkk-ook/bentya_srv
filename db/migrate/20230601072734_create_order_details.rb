class CreateOrderDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :order_details do |t|
      t.references :order, foreign_key: true, comment: "注文ID"
      t.integer :count, comment: "個数"
      t.date :provision_on, comment: "お届け日"

      t.timestamps
    end
  end
end
