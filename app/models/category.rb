class Category < ApplicationRecord
    #--------------------------------------------------
    # 論理削除
    #--------------------------------------------------
    include Discard::Model
    # 論理削除したレコードを返さないように
    default_scope -> { kept }

    #--------------------------------------------------
    # リレーション
    #--------------------------------------------------
    # 商品 一対多
    has_many :products

    #-----------------------------
    # バリデーション
    #-----------------------------
    validates :name, presence: true
    validates :image, presence: true
    validates :closing_time, presence: true

    #--------------------------------------------------
    # uploaderと紐付け
    #--------------------------------------------------
    mount_uploader :image, CategoryImageUploader
    mount_uploader :icon, CategoryIconUploader

    #--------------------------------------------------
    # コールバック
    #--------------------------------------------------
    # 論理削除後、関連する子モデルや中間テーブルも削除
    after_discard do
        products.each(&:discard)
    end
end
