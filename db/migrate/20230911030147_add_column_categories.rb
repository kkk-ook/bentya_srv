class AddColumnCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :categories, :closing_time, :string
    add_column :categories, :is_same_day_reservation, :boolean
  end
end
