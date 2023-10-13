class Client < ApplicationRecord
    #--------------------------------------------------
    # 論理削除
    #--------------------------------------------------
    include Discard::Model
    # 論理削除したレコードを返さないように
    default_scope -> { kept }

    #--------------------------------------------------
    # リレーション
    #--------------------------------------------------
    # 納品場所 一対多
    has_many :delivery_locations
    accepts_nested_attributes_for :delivery_locations

    # 顧客別商品設定 多対多
    has_many :client_product_settings
    has_many :products, through: :client_product_settings
    accepts_nested_attributes_for :client_product_settings

    #-----------------------------
    # バリデーション
    #-----------------------------
    validates :code,
        presence: true,
        length: {minimum:4, maxmum:4}
    validates :company_name, presence: true
    validates :postal_code,
        presence: true,
        format: { with: /\A[0-9]+\z/}
    validates :prefecture, presence: true
    validates :address1, presence: true
    validates :tel,
        presence: true,
        numericality: {only_integer: true},
        length: { in: 10..11 },
        format: { with: /\A[0-9]+\z/}

    # 顧客更新時に「is_discard: true」であれば納品場所を論理削除
    def delivery_locations_discard(params)
        params[:client][:delivery_locations_attributes].each do |delivery_location|
            if delivery_location[:is_discard]
                delivery_location = DeliveryLocation.find(delivery_location[:id])
                delivery_location.discard!
            end
        end
    end

    #--------------------------------------------------
    # コールバック
    #--------------------------------------------------
    # バリデーション前にtel、postal_codeを整形
    before_validation do
        self.tel = self.tel.tr('０-９', '0-9').gsub(/[-ー]/, '')
        self.postal_code = self.postal_code.tr('０-９', '0-9').gsub(/[-ー]/, '')
    end

    # 論理削除後、関連する子モデルや中間テーブルも削除
    after_discard do
        delivery_locations.each(&:discard)
        client_product_settings.each(&:discard)
    end
end
