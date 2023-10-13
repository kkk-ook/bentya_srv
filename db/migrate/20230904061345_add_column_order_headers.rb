class AddColumnOrderHeaders < ActiveRecord::Migration[7.0]
  def change
    add_column :order_headers, :status, :string
  end
end
