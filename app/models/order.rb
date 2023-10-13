class Order < ApplicationRecord

    #--------------------------------------------------
    # アクセサメソッド
    #--------------------------------------------------
    attr_accessor :product_price         # 商品価格
    def product_price
        @product_price || nil
    end

    #--------------------------------------------------
    # 論理削除
    #--------------------------------------------------
    include Discard::Model
    # 論理削除したレコードを返さないように
    default_scope -> { kept }

    #--------------------------------------------------
    # リレーション
    #--------------------------------------------------
    belongs_to :product
    belongs_to :client_product_setting, optional: true

    # 注文内訳
    belongs_to :order_header
    has_many :order_details, -> { order('provision_on') }
    accepts_nested_attributes_for :order_details

    #--------------------------------------------------
    # バリデーション
    #--------------------------------------------------
    validates :product_name,
        presence: true
    validates :order_count,
        presence: true,
        numericality: { greater_than_or_equal_to: 0 }
    validates :total_price,
        presence: true,
        numericality: { greater_than_or_equal_to: 0 }

    #--------------------------------------------------
    # コールバック
    #--------------------------------------------------
    # 論理削除後、関連する子モデルや中間テーブルも削除
    after_discard do
        order_details.each(&:discard)
    end

end
