# frozen_string_literal: true

class Administrator < ActiveRecord::Base
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable,
            :recoverable, :rememberable, :validatable
    include DeviseTokenAuth::Concerns::User

    #--------------------------------------------------
    # 論理削除
    #--------------------------------------------------
    include Discard::Model
    # 論理削除したレコードを返さないように
    default_scope -> { kept }

    #--------------------------------------------------
    # バリデーション
    #--------------------------------------------------
    validates :name,
        presence: true
    validates :email,
        presence: true
    VALID_PASSWORD_REGEX = /\A[a-zA-Z0-9]+\z/ #小文字と大文字、半角英数字
    validates :password,
        presence: true,
        format: { with: VALID_PASSWORD_REGEX},
        on: :create
    validates :password_confirmation,
        presence: true,
        if: -> { password.present? && password != password_confirmation },
        on: :update

    #--------------------------------------------------
    # コールバック
    #--------------------------------------------------
    # アカウント削除時にメールアドレスを変更
    after_discard -> do
        dummy_email = loop do
        dummy_email = SecureRandom.alphanumeric(20) + "@example.com"
        break dummy_email unless self.class.exists?(uid: dummy_email)
        end
        self.update_columns(uid: dummy_email, email: dummy_email)
    end
end
