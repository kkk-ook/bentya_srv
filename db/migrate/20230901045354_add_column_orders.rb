class AddColumnOrders < ActiveRecord::Migration[7.0]
  def change
    add_reference :orders, :order_header, foreign_key: true, comment: "注文ID"
  end
end
