class DeliveryCourse < ApplicationRecord
    #--------------------------------------------------
    # 論理削除
    #--------------------------------------------------
    include Discard::Model
    # 論理削除したレコードを返さないように
    default_scope -> { kept }

    #--------------------------------------------------
    # リレーション
    #--------------------------------------------------
    # 配送ルート 多対多
    has_many :delivery_orders
    has_many :delivery_locations, through: :delivery_orders
    accepts_nested_attributes_for :delivery_orders

    # 配送ルート更新時に「is_discard: true」であれば配送順を論理削除
    def delivery_orders_discard(params)
        params[:delivery_course][:delivery_orders_attributes].each do |delivery_order|
            if delivery_order[:is_discard]
                delivery_order = DeliveryOrder.find(delivery_order[:id])
                # 今の順番を変数に
                now_position = delivery_order.position
                delivery_order.position = nil
                delivery_order.discard!

                #  削除したら今の順番以降のpositionを1ずつ減らしていく
                delivery_orders = DeliveryOrder.where(delivery_course_id: params[:id]).where("position > ?", now_position)
                delivery_orders.each do |delivery_order|
                    puts delivery_order.inspect
                    delivery_order.update!(position: delivery_order.position - 1)
                end
            end
        end
    end

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
    end
end
