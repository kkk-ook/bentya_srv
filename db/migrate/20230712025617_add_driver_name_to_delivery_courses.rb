class AddDriverNameToDeliveryCourses < ActiveRecord::Migration[7.0]
  def change
    add_column :delivery_courses, :driver_name, :string
  end
end
