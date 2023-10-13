class CreateDeliveryOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :delivery_orders do |t|
      t.references :delivery_course, foreign_key: true, comment: "配送コースID"
      t.references :delivery_location, foreign_key: true, comment: "納品場所ID"
      t.integer :position, comment: "配送順"

      t.datetime :discarded_at, precision: 6
      t.timestamps
    end
  end
end
