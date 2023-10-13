require 'date'
class Api::Front::OrdersController < ApplicationController
    before_action :authenticate_api_user!
    #--------------------------------------------------
    #  過去注文一覧
    #  GET /api/front/orders
    #--------------------------------------------------
    def index
        order_headers = OrderHeader.where(user_id: @resource.id).order(created_at: :desc)

        order_header_ids_to_update = []

        order_headers.includes(orders: { product: :category }).each do |order_header|
            categories = order_header.orders.joins(product: :category).pluck('categories.is_same_day_reservation', 'categories.closing_time')

            # ①is_same_day_reservationが前日ならfalse格納、trueなら空
            prior_day_categories = categories.select { |is_same_day, _| !is_same_day }

            # puts "%%%%%%%%%%%%%%%%"
            # puts prior_day_categories.inspect


            if prior_day_categories.any?
            #--------------------------------------------------
            # ② ①で前日(false)の場合
            #--------------------------------------------------
                # お届け日と締め切り日時を取得
                provision_and_deadlines = order_header.orders.joins(:order_details, product: :category)
                                                             .pluck('order_details.provision_on', 'categories.is_same_day_reservation', 'categories.closing_time')

            # 注文の中でお届け日と締切時間が一番早いものを取得
                closest_deadline = provision_and_deadlines.map do |provision_on, is_same_day, closing_time_string|
                    deadline_date = is_same_day ? provision_on : provision_on - 1.day

                # お届け日前日が休日の数だけ締切日を前倒しにするチェック
                    while !is_same_day && Holiday.exists?(holiday_date: deadline_date)
                        deadline_date -= 1.day
                    end

                    Time.parse("#{deadline_date} #{closing_time_string}")
                end.min

                # puts "@@@@@@@@@@@@@@@@@@@@@@@@"
                # puts closest_deadline.inspect
                if Time.current >= closest_deadline
                    order_header_ids_to_update << order_header.id
                end

            else
            #--------------------------------------------------
            # ② ①で当日(true)の場合
            #--------------------------------------------------
                # 注文の中でお届け日と締切時間が一番早いものを取得
                provision_on = order_header.orders.joins(:order_details).pluck('order_details.provision_on').min

                same_day_categories = categories.select { |is_same_day, _| is_same_day }
                # 当日予約可能な商品の中で最も早い締め切り時刻を格納
                earliest_closing_time_string_for_same_day = same_day_categories.map(&:last).min
                cancel_deadline = Time.parse("#{provision_on} #{earliest_closing_time_string_for_same_day}")

                # puts "当日の締切時間を過ぎたらキャンセル不可"
                # puts cancel_deadline.inspect

                if Time.current >= cancel_deadline
                    order_header_ids_to_update << order_header.id
                end
            end
        end

        OrderHeader.where(id: order_header_ids_to_update, status: 'success').update_all(cancel_time: 'true')


        render json: { order_headers: order_headers }, include: {orders: { include: { product: { include: :product_images }, client_product_setting: {}, order_details: {} } } }, status: 200
    end


    #--------------------------------------------------
    #  注文登録
    #  POST /api/front/orders
    #----------------------------z----------------------
    def create
        Order.transaction do
            order_header = OrderHeader.new(order_header_params)

            product = Product.find_by(id: order_header.orders.first.product_id)
            is_purchaseable, error_message = purchaseable?(product)
            unless is_purchaseable
                render json: { errors: ["購入可能時間外の為、購入できません"] }, status: :unprocessable_entity
                return
            end

            order_header.user_id = @resource.id
            client = @resource.client
            order_header.orders.each do |order|
                order.user_id = @resource.id
                client_product_setting = ClientProductSetting.find_by(product_id: order.product_id, client_id: client.id)
                raise "Product does not exist" if client_product_setting.nil?
                order.client_product_setting_id = client_product_setting.id
                order.product_name = Product.find(order.product_id).name
                order.order_count = order.order_details.sum { |order_detail| order_detail.count.to_i }
                order.total_price = order.product_price * order.order_count
            end

            if order_header.save
                stripe_customer_id = @resource.stripe_customer_id.presence
                customer = @resource&.stripe_customer_id.presence
                line_items = []
                order_header.orders.each do |order|
                    descriptions = order.order_details.map do |order_detail|
                        provision_date = order_detail.provision_on.strftime("%Y年%-m月%-d日")
                        "（#{provision_date} #{order_detail.count}個）"
                    end
                    description = descriptions.join(", ")
                    line_items << {
                            price_data: {
                                    currency: "jpy",
                                    unit_amount: order.total_price,
                                    product_data: {
                                            name: order.product_name,
                                            description: description,
                                    }
                            },
                            quantity: 1
                    }
                end

                success_url = "#{Constants::FRONT_URL}/cart/complete"
                cancel_url = "#{Constants::FRONT_URL}/error"
                stripe_params = {
                    customer: stripe_customer_id,
                    success_url: success_url,
                    cancel_url: cancel_url,
                    line_items: line_items,
                    client_reference_id: order_header.id,
                    payment_method_options: {
                        card: {
                            # カードをcustomer_idに紐つけて次回も使えるようにする設定
                            setup_future_usage: 'on_session',
                        }
                    },
                    mode: 'payment',
                    payment_intent_data: {
                        description: "user_id=#{order_header.user_id}, name=#{@resource.last_name} #{@resource.first_name}, email=#{@resource.email}, order_header_id=#{order_header.id}",
                    }
                }

                begin
                    session = Stripe::Checkout::Session.create(stripe_params)
                    render json: { url: session.url }, status: 200
                rescue Stripe::StripeError => e
                    error_message = e.message
                    error_code = e.code
                    puts error_message
                    raise ActionController::BadRequest, "決済手段が不正のため、購入処理できません。"
                end

            else
                render json: { errors: ["注文に失敗しました"] }, status: 422
            end                
        end
    end

    #--------------------------------------------------
    #  全注文キャンセル
    #  DELETE /api/front/orders/:id
    #--------------------------------------------------
    def destroy
        order_header = @resource.order_headers.find_by(id: params[:id])

        unless order_header
            render json: { errors: ["該当する注文が見つかりません"] }, status: 400
            return
        end

        categories = order_header.orders.joins(product: :category).pluck('categories.is_same_day_reservation', 'categories.closing_time')
        # puts "111111111111111"
        # puts categories.inspect

        # ①is_same_day_reservationが前日ならfalse格納、trueなら空
        prior_day_categories = categories.select { |is_same_day, _| !is_same_day }
        # puts "22222222222222"
        # puts prior_day_categories.inspect

        # ② ①で前日(false)の場合
        if prior_day_categories.any?
            # お届け日と締め切り日時を取得
            provision_and_deadlines = order_header.orders.joins(:order_details, product: :category)
                                                         .pluck('order_details.provision_on',
                                                                'categories.is_same_day_reservation',
                                                                'categories.closing_time')

            # 注文の中でお届け日と締切時間が一番早いものを取得
            closest_deadline = provision_and_deadlines.map do |provision_on, is_same_day, closing_time_string|
                deadline_date = is_same_day ? provision_on : provision_on - 1.day

                # お届け日前日が休日の数だけ締切日を前倒しにするチェック
                while !is_same_day && Holiday.exists?(holiday_date: deadline_date)
                    deadline_date -= 1.day
                end

                Time.parse("#{deadline_date} #{closing_time_string}")
            end.min

            # puts "最も早いキャンセル期限"
            # puts closest_deadline.inspect

            if Time.current >= closest_deadline
                render json: { errors: ["キャンセル期限を過ぎています"] }, status: 400
                return
            end

        else
            # ② ①で当日(true)の場合
            # 注文の中でお届け日と締切時間が一番早いものを取得
            provision_on = order_header.orders.joins(:order_details).pluck('order_details.provision_on').min

            same_day_categories = categories.select { |is_same_day, _| is_same_day }
            # 当日予約可能な商品の中で最も早い締め切り時刻を格納
            earliest_closing_time_string_for_same_day = same_day_categories.map(&:last).min
            cancel_deadline = Time.parse("#{provision_on} #{earliest_closing_time_string_for_same_day}")

            # puts "当日の締切時間を過ぎたらキャンセル不可"
            # puts cancel_deadline.inspect

            if Time.current >= cancel_deadline
                render json: { errors: ["キャンセル期限を過ぎています"] }, status: 400
                return
            end
        end

        order_header.update(status: 'cancel')

        begin
            payment_intent = Stripe::PaymentIntent.retrieve(order_header.stripe_payment_intent_id)
            Stripe::Refund.create({
                payment_intent: payment_intent
            })
        rescue Stripe::StripeError => e
            error_message = e.message
            render json: { errors: ["返金処理に失敗しました"] }, status: 400
            return
        end

        render json: { message: "注文をキャンセルしました" }, status: 200
    end


    #--------------------------------------------------
    # チェック処理
    #--------------------------------------------------
    def purchaseable?(product)
        closing_hour = Time.parse(product.category.closing_time).hour

        current_hour = Time.now.hour

        days_prior_date = order_header_params[:orders_attributes].map do |order|
            order[:order_details_attributes].map { |detail| detail[:provision_on] }
        end.flatten.min

        # 二日以上前はチェックをスキップ
        if days_prior_date && (Date.parse(days_prior_date) - Date.today).to_i >= 2
            return true, nil
        end

        # 当日予約のチェック
        if product.category.is_same_day_reservation
            if current_hour >= closing_hour
                if days_prior_date && (Date.parse(days_prior_date) - Date.today).to_i >= 1
                    return true, nil
                end
                return false
            end
        else
        # 前日予約のチェック
            if current_hour >= closing_hour
                return false
            end
        end

        return true, nil
    end


    private
    def order_header_params
        params.require(:order_header).permit(
            :user_id,
            :total_price,
            :total_count,
            :stripe_payment_intent_id,
            orders_attributes: [
                :user_id,
                :product_id,
                :client_product_setting_id,
                :order_header_id,
                :product_name,
                :product_price,
                :total_price,
                order_details_attributes: [:id, :count, :provision_on, :order_id]
            ]
        )
    end
end