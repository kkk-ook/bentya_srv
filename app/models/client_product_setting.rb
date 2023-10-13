class ClientProductSetting < ApplicationRecord
    #--------------------------------------------------
    # 論理削除
    #--------------------------------------------------
    include Discard::Model
    # 論理削除したレコードを返さないように
    default_scope -> { kept }

    #-----------------------------
    # バリデーション
    #-----------------------------
    validates :price, presence: true
    validates :is_public, inclusion: {in: [true, false]}

    #--------------------------------------------------
    # リレーション
    #--------------------------------------------------
    # 注文 一対多
    has_many :orders

    # 顧客別商品設定 多対多
    belongs_to :client
    belongs_to :product
end