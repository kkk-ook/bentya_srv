# frozen_string_literal: true

class User < ActiveRecord::Base
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable,
            :recoverable, :rememberable, :validatable, :confirmable
    include DeviseTokenAuth::Concerns::User


    #--------------------------------------------------
    # 論理削除
    #--------------------------------------------------
    include Discard::Model
    # 論理削除したレコードを返さないように
    default_scope -> { kept }

    #--------------------------------------------------
    # リレーション
    #--------------------------------------------------
    belongs_to :delivery_location
    has_one :client, through: :delivery_location

    # 注文 一対多
    has_many :order_headers, -> { order('created_at') }
    has_many :products, through: :orders

    #カート 一対多
    has_many :carts, dependent: :destroy


    #-----------------------------
    # バリデーション
    #-----------------------------
    validates :last_name,
        presence: true
    validates :first_name,
        presence: true
    validates :last_name_kana,
        presence: true,
        format: { with: /\A[ァ-ヶー－]+\z/}
    validates :first_name_kana,
        presence: true,
        format: { with: /\A[ァ-ヶー－]+\z/}
    validates :email,
        presence: true
    validates :tel,
        presence: true,
        numericality: {only_integer: true},
        length: { in: 10..11 },
        format: { with: /\A[0-9]+\z/}
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
    # ユーザー登録後にuser_codeを自動付与（U + userのid 例:U00123）
    after_create_commit -> do
        user_code = "U" + format("%05d", self.id)
        self.update_columns(user_code: user_code)
    end

    # userの新規登録に成功した時のみ、Stripe::Customerを作成し、stripe_customer_id登録
    after_create -> do
        stripe_customer = Stripe::Customer.create({
            email: self.email,
            name: (self.last_name + " " + self.first_name),
            description: "customer_id=#{self.id}",
        })
        self.update(stripe_customer_id: stripe_customer.id)
    end

    # アカウント削除時にメールアドレスを変更
    after_discard -> do
        dummy_email = loop do
        dummy_email = SecureRandom.alphanumeric(20) + "@example.com"
        break dummy_email unless self.class.exists?(uid: dummy_email)
        end
        self.update_columns(uid: dummy_email, email: dummy_email)
    end

    # バリデーション前にtel、telを整形
    before_validation do
        self.tel = self.tel.tr('０-９', '0-9').gsub(/[-ー]/, '')
    end
end
