class CreateTerms < ActiveRecord::Migration[7.0]
  def change
    create_table :terms do |t|
      t.string :title, comment: "タイトル"
      t.text :body, comment: "本文"

      t.timestamps
    end
  end
end
