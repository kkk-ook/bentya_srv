class DeviseTokenAuthCreateAdministrators < ActiveRecord::Migration[7.0]
  def change

    create_table(:administrators) do |t|
      ## User Info
			t.string :name, comment: "管理者名"
      t.string :email, comment: "メールアドレス"
      t.datetime :discarded_at, precision: 6

      ## Required
      t.string :provider, :null => false, :default => "email"
      t.string :uid, :null => false, :default => ""

      ## Database authenticatable
      t.string :encrypted_password, :null => false, :default => ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.boolean  :allow_password_change, :default => false

      ## Rememberable
      t.datetime :remember_created_at

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, :default => 0, :null => false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      ## Tokens
      t.json :tokens

      t.timestamps
    end

    add_index :administrators, :email,                unique: true
    add_index :administrators, [:uid, :provider],     unique: true
    add_index :administrators, :reset_password_token, unique: true
    add_index :administrators, :confirmation_token,   unique: true
    # add_index :administrators, :unlock_token,         unique: true
  end
end
