class Api::Admin::OrderCancelsController < ApplicationController

    #--------------------------------------------------
    #  キャンセル注文一覧
    #  GET /api/admin/order_cancels
    #--------------------------------------------------
    def index
        delivery_locations = DeliveryLocation.includes(delivery_orders: :delivery_course, users: { order_headers: { orders: [:product, :order_details] } })
        orders_array = []
    
        delivery_locations.each do |delivery_location|
            order_count_by_products = {}
            users_with_order_headers = delivery_location.users.includes(order_headers: { orders: :order_details })
    
            users_with_order_headers.each do |user|
                cancelled_order_headers = user.order_headers.where(status: 'cancel')
    
                cancelled_order_headers.each do |order_header|
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
    
        render json: { order: orders_array }, status: 200
    end


    #--------------------------------------------------
    #  キャンセル注文詳細
    #  GET /api/admin/order_cancels/:id
    #--------------------------------------------------
    def show
        delivery_location = DeliveryLocation.find(params[:id])
        result = []
    
        delivery_day = params[:delivery_day].present? ? Date.parse(params[:delivery_day]) : Date.today
    
        users_with_order_headers = delivery_location.users.includes(order_headers: { orders: :order_details })
    
        users_with_order_headers.each do |user|
            orders_by_product = {}
    
            user.order_headers.where(status: 'cancel').each do |order_header|
    
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
    #  キャンセル注文検索
    #  GET /api/admin/order_cancels/search
    # --------------------------------------------------
    def search
        delivery_day = params[:delivery_day].present? ? Date.parse(params[:delivery_day]) : Date.today
        
        locations = DeliveryLocation.left_outer_joins(users: { order_headers: { orders: :order_details } })
                                    .left_outer_joins(client: {})
                                    .left_outer_joins(delivery_orders: :delivery_course)
                                    .includes(users: { order_headers: { orders: [:product, :order_details] } })
                                    .references(client: {})
        
        locations = locations.where("DATE(order_details.provision_on) = ?", delivery_day)
        locations = locations.where("delivery_courses.name LIKE ?", "%#{params[:delivery_course]}%") if params[:delivery_course].present?
        locations = locations.where("clients.name LIKE ?", "%#{params[:client_name]}%") if params[:client_name].present?
        locations = locations.where("clients.code LIKE ?", "%#{params[:client_code]}%") if params[:client_code].present?
        
        orders_array = []
        
        locations.each do |location|
            order_count_by_products = Hash.new(0)
            delivery_order = location.delivery_orders.first
            
            location.users.each do |user|
                user.order_headers.where(status: 'cancel').each do |order_header|
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
        
        render json: { delivery_day: delivery_day, order: orders_array}, status: 200
    end
end
