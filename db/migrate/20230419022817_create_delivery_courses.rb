class CreateDeliveryCourses < ActiveRecord::Migration[7.0]
  def change
    create_table :delivery_courses do |t|
      t.string :name, comment: "配送コース名"
      
      t.datetime :discarded_at, precision: 6
      t.timestamps
    end
  end
end
