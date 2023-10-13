class Product < ApplicationRecord
    #--------------------------------------------------
    # 論理削除
    #--------------------------------------------------
    include Discard::Model
    # 論理削除したレコードを返さないように
    default_scope -> { kept }

    #--------------------------------------------------
    # リレーション
    #--------------------------------------------------
    belongs_to :category

    # 商品写真 一対多
    has_many :product_images, -> { order('id') }
    accepts_nested_attributes_for :product_images

    # 注文 一対多
    has_many :orders

    #カート 一対多
    has_many :carts

    # 顧客別商品設定 多対多
    has_many :client_product_settings
    has_many :clients, through: :client_product_settings

    #-----------------------------
    # バリデーション
    #-----------------------------
    validates :name, presence: true
    validates :abbreviated_name, presence: true
    validates :is_public, inclusion: {in: [true, false]}
    validates :is_same_day_reservation, inclusion: {in: [true, false]}
    validates :common_selling_price, presence: true

    #--------------------------------------------------
    # コールバック
    #--------------------------------------------------
    after_update -> do
        if self.is_public == false
            ClientProductSetting.where(product_id: self.id).update_all(is_public: false)
        end
    end

    # 論理削除後、関連する子モデルや中間テーブルも削除
    after_discard do
        client_product_settings.each(&:discard)
    end

    #--------------------------------------------------
    # Attributes
    #--------------------------------------------------
    attribute :is_public, :boolean, default: false
    attribute :is_same_day_reservation, :boolean, default: false


    #--------------------------------------------------
    # スコープ
    #--------------------------------------------------
    scope :publish, -> { where(is_public: true) }
end
