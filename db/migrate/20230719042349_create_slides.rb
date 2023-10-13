class CreateSlides < ActiveRecord::Migration[7.0]
  def change
    create_table :slides do |t|
      t.integer :position, comment: "順番"
      t.string :image, comment: "画像"

      t.timestamps
    end
  end
end
