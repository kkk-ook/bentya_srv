class CreateHolidays < ActiveRecord::Migration[7.0]
  def change
    create_table :holidays do |t|
      t.date :holiday_date, comment: "休日"
      
      t.timestamps
    end
  end
end
