require 'csv'
require 'date'
class Api::Admin::OrdersController < ApplicationController
    #--------------------------------------------------
    #  注文一覧
    #  GET /api/admin/orders
    #--------------------------------------------------
    def index
        delivery_locations = DeliveryLocation.includes(delivery_orders: :delivery_course, users: { order_headers: { orders: [:product, :order_details] } })
        orders_array = []

        delivery_locations.each do |delivery_location|
            order_count_by_products = {}
            users_with_order_headers = delivery_location.users.includes(order_headers: { orders: :order_details })

            users_with_order_headers.each do |user|
                successful_order_headers = user.order_headers.where(status: 'success')

                successful_order_headers.each do |order_header|
                    order_header.orders.each do |order|
                        order.order_details.each do |order_detail|
                            provision_date = Date.parse(order_detail.provision_on.to_s)
                            if provision_date == Date.today
                                product_id = order.product_id
                                order_count = order_detail.count

                                order_count_by_products[product_id] ||= 0
                                order_count_by_products[product_id] += order_count
                            end
                        end
                    end
                end
            end

            delivery_order = delivery_location.delivery_orders.order('updated_at DESC').first
            order_count_by_products = order_count_by_products.map { |id, count| { product_id: id, count: count } }

            orders_array << {
                delivery_course_id: delivery_order&.delivery_course&.id,
                driver_name: delivery_order&.delivery_course&.driver_name,
                delivery_order_position: delivery_order&.position,
                delivery_location_id: delivery_location.id,
                order_count_by_products: order_count_by_products
            } unless order_count_by_products.empty?
        end

        response = orders_array.sort_by { |order| order[:delivery_order_position].to_i }

        render json: { order: response }, status: 200
    end

    #--------------------------------------------------
    #  注文詳細
    #  GET /api/admin/orders/:id
    #--------------------------------------------------
    def show
        delivery_location = DeliveryLocation.find(params[:id])
        result = []

        delivery_day = params[:delivery_day].present? ? Date.parse(params[:delivery_day]) : Date.today

        users_with_order_headers = delivery_location.users.includes(order_headers: { orders: :order_details })

        users_with_order_headers.each do |user|
            orders_by_product = {}

            user.order_headers.where(status: 'success').each do |order_header|

                order_header.orders.each do |order|
                    order.order_details.where(provision_on: delivery_day.all_day).each do |order_detail|
                        product_id = order.product_id
                        orders_by_product[product_id] ||= 0
                        orders_by_product[product_id] += order_detail.count
                    end
                end
            end

            unless orders_by_product.empty?
                user_order_data = {
                    user_id: user.id,
                    delivery_order: orders_by_product.map { |product_id, count| { product_id: product_id, count: count } }
                }
                result << user_order_data
            end
        end

        response = {
            delivery_day: delivery_day,
            delivery_location_id: delivery_location.id,
            users: result
        }

        render json: response, status: 200
    end

    #--------------------------------------------------
    #  注文検索
    #  GET /api/admin/orders/search
    # --------------------------------------------------
    # def search
    #     delivery_day = params[:delivery_day].present? ? Date.parse(params[:delivery_day]) : Date.today

    #     locations = DeliveryLocation.left_outer_joins(users: { order_headers: { orders: :order_details } })
    #                                 .left_outer_joins(client: {})
    #                                 .left_outer_joins(delivery_orders: :delivery_course)
    #                                 .includes(users: { order_headers: { orders: [:product, :order_details] } })
    #                                 .references(client: {})

    #     locations = locations.where("DATE(order_details.provision_on) = ?", delivery_day)
    #     locations = locations.where("delivery_courses.name LIKE ?", "%#{params[:delivery_course]}%") if params[:delivery_course].present?
    #     locations = locations.where("clients.name LIKE ?", "%#{params[:client_name]}%") if params[:client_name].present?
    #     locations = locations.where("clients.code LIKE ?", "%#{params[:client_code]}%") if params[:client_code].present?

    #     orders_array = []

    #     locations.each do |location|
    #         order_count_by_products = Hash.new(0)
    #         delivery_order = location.delivery_orders.first
            
    #         location.users.each do |user|
    #             user.order_headers.where(status: 'success').each do |order_header|
    #                 order_header.orders.each do |user_order|
    #                     user_order.order_details.each do |order_detail|
    #                         provision_date = Date.parse(order_detail.provision_on.to_s)
    #                         if provision_date == delivery_day
    #                             order_count_by_products[user_order.product_id] += order_detail.count
    #                         end
    #                     end
    #                 end
    #             end
    #         end

    #         data_hash = {
    #             delivery_course_id: delivery_order&.delivery_course&.id,
    #             driver_name: delivery_order&.delivery_course&.driver_name,
    #             delivery_order_position: delivery_order&.position,
    #             delivery_location_id: location.id,
    #             order_count_by_products: order_count_by_products.map { |product_id, count| { product_id: product_id, count: count } }
    #         }
            
    #         orders_array << data_hash unless order_count_by_products.empty?
    #     end
        
    #     response = orders_array.sort_by { |order| order[:delivery_order_position].to_i }

    #     render json: { delivery_day: delivery_day, order: response}, status: 200
    # end

    def search
        delivery_day = params[:delivery_day].present? ? Date.parse(params[:delivery_day]) : Date.today

        order_counts = Order.joins(:order_header, :order_details)
                            .where(order_headers: { status: 'success' })
                            .where("DATE(order_details.provision_on) = ?", delivery_day)
                            .group(:product_id).sum('order_details.count')
        
        products_order_aggregation = order_counts.map do |product_id, count|
            {
                product_id: product_id,
                count: count
            }
        end
    
        # Remaining logic of the original search action
        locations = DeliveryLocation.left_outer_joins(users: { order_headers: { orders: :order_details } })
                                    .left_outer_joins(client: {})
                                    .left_outer_joins(delivery_orders: :delivery_course)
                                    .includes(users: { order_headers: { orders: [:product, :order_details] } })
                                    .references(client: {})
    
        orders_array = []

        locations.each do |location|
            order_count_by_products = Hash.new(0)
            delivery_order = location.delivery_orders.first
            
            location.users.each do |user|
                user.order_headers.where(status: 'success').each do |order_header|
                    order_header.orders.each do |user_order|
                        user_order.order_details.each do |order_detail|
                            provision_date = Date.parse(order_detail.provision_on.to_s)
                            if provision_date == delivery_day
                                order_count_by_products[user_order.product_id] += order_detail.count
                            end
                        end
                    end
                end
            end

            data_hash = {
                delivery_course_id: delivery_order&.delivery_course&.id,
                driver_name: delivery_order&.delivery_course&.driver_name,
                delivery_order_position: delivery_order&.position,
                delivery_location_id: location.id,
                order_count_by_products: order_count_by_products.map { |product_id, count| { product_id: product_id, count: count } }
            }
            
            orders_array << data_hash unless order_count_by_products.empty?
        end
        
        response = orders_array.sort_by { |order| order[:delivery_order_position].to_i }

    render json: {
        products_order_aggregation: products_order_aggregation,
        delivery_day: delivery_day,
        order: response # Assuming `response` is the final data from the original search action
    }, status: 200
    end

    #--------------------------------------------------
    #  配送集計表ダウンロード
    #  GET /api/admin/orders/:id/download
    #--------------------------------------------------
    def download
        # 受け取ったdelivery_course_idの配送シート作成用にjsonを作成
        today = Date.today
        delivery_course = DeliveryCourse.find(params[:id])
        products = Product.where(is_public: true).order(:created_at)
        delivery_orders = DeliveryOrder.where(delivery_course_id: params[:id]).order(:position)

        delivery_list = {
            products: products.map do |product|
                {
                    abbreviated_name: product.abbreviated_name
                }
            end,
            delivery_courses: {
                name: delivery_course.name,
                delivery_locations: delivery_orders.map do |delivery_order|
                    client = delivery_order.delivery_location.client
                    user_ids = delivery_order.delivery_location.users.map(&:id)
                    # 注文を以下の条件で絞る
                    # ・本日提供
                    # ・納品場所に紐つくuser
                    # ・stripe_payment_intent_idに値が入っているもの（支払いが完了しているもの）
                    # Now we get orders through order_headers given the new relationship.
                    orders = Order.joins("INNER JOIN order_headers ON orders.order_header_id = order_headers.id")
                    .joins(:product, :order_details)
                    .where('order_headers.user_id' => user_ids)
                    .where('order_details.provision_on = ?', today)
                    .where.not(stripe_payment_intent_id: nil)
                    {
                        code: client.code,
                        client_name: client.name,
                        name: delivery_order.delivery_location.name,
                        tel: client.tel,
                        orders: products.map do |product|
                            {
                                order_count: orders.where(product_id: product.id).sum('order_details.count')  # Adjusted to sum order_details.count
                            }
                        end,
                        memo: client.memo
                    }
                end
            }
        }
        render json: {delivery_list: delivery_list}
    end

    #--------------------------------------------------
    #  注文総集計
    #  GET /api/admin/orders/order_count
    #--------------------------------------------------
    def order_count
        today = Date.today
        
        order_counts = Order.joins(:order_header, :order_details)
                            .where(order_headers: { status: 'success' })
                            .where('order_details.provision_on = ?', today)
                            .group(:product_id).sum('order_details.count')

        products_order_aggregation = order_counts.map do |product_id, count|
            {
                product_id: product_id,
                count: count
            }
        end

        render json: { products_order_aggregation: products_order_aggregation }, status: 200
    end
end