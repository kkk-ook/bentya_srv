class DeliveryLocation < ApplicationRecord
    #--------------------------------------------------
    # 論理削除
    #--------------------------------------------------
    include Discard::Model
    # 論理削除したレコードを返さないように
    default_scope -> { kept }

    #--------------------------------------------------
    # リレーション
    #--------------------------------------------------
    belongs_to :client

    # ユーザー 一対多
    has_many :users

    # 配送ルート 多対多
    has_many :delivery_orders
    has_many :delivery_courses, through: :delivery_orders

    #-----------------------------
    # バリデーション
    #-----------------------------
    validates :name, presence: true

    #--------------------------------------------------
    # コールバック
    #--------------------------------------------------
    # 論理削除後、関連する子モデルや中間テーブルも削除
    after_discard do
        delivery_orders.each(&:discard)
        users.each(&:discard)
    end
end
