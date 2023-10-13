class CreateDeliveryLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :delivery_locations do |t|
      t.references :client, foreign_key: true, comment: "顧客ID"
      t.string :name, comment: "納品場所名"

      t.datetime :discarded_at, precision: 6
      t.timestamps
    end
  end
end
