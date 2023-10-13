class Api::Admin::DeliveryCoursesController < ApplicationController
    before_action :authenticate_api_administrator!
    #--------------------------------------------------
    #  配送コース一覧
    #  GET /api/admin/delivery_courses
    #--------------------------------------------------
    def index
        params[:limit] ? limit = params[:limit].to_i : limit = nil
        params[:offset] ? offset = params[:offset].to_i : offset = 0
    
        delivery_courses = DeliveryCourse.preload(:delivery_orders).order(:created_at)
        delivery_courses = delivery_courses.limit(limit).offset(offset) if limit.present?
    
        delivery_courses_with_orders = []
        delivery_count = {}
    
        delivery_courses.each do |course|
            delivery_order_details = []
            course.delivery_orders.each do |order|
                delivery_order_details << {
                    id: order.id,
                    delivery_course_id: order.delivery_course_id,
                    delivery_location_id: order.delivery_location_id,
                    position: order.position,
                    discarded_at: order.discarded_at,
                    created_at: order.created_at,
                    updated_at: order.updated_at
                }
            end
    
            delivery_courses_with_orders << {
                id: course.id,
                name: course.name,
                discarded_at: course.discarded_at,
                created_at: course.created_at,
                updated_at: course.updated_at,
                driver_name: course.driver_name,
                delivery_location_count: delivery_order_details.count,
                delivery_orders: delivery_order_details
            }
    
            delivery_count[course.id] = delivery_order_details.count
        end
    
        render json: { delivery_courses: delivery_courses_with_orders }, status: 200
    end

    #--------------------------------------------------
    #  配送コース登録
    #  GET /api/admin/delivery_courses
    #--------------------------------------------------
    def create
        DeliveryCourse.transaction do
            delivery_course = DeliveryCourse.new(delivery_course_params)
            if delivery_course.save
                render json: { success: true }, status: 200
            else
                render json: { errors: delivery_course.errors.full_messages }, status: :unprocessable_entity
            end
        end
    end

    #--------------------------------------------------
    #  配送コース編集
    #  GET /api/admin/delivery_courses/:id/edit
    #--------------------------------------------------
    def edit
        delivery_course = DeliveryCourse.preload(:delivery_orders).find(params[:id])
        render json: { delivery_course: delivery_course }, include: :delivery_orders, status: 200
    end

    #--------------------------------------------------
    #  配送コース編集
    #  PUT /api/admin/delivery_courses/:id
    #--------------------------------------------------
    def update
        DeliveryCourse.transaction do
            delivery_course = DeliveryCourse.find(params[:id])
            if delivery_course.update(delivery_course_params)
                delivery_course.delivery_orders_discard(params)
                render json: { success: true }, status: 200
            else
                render json: { errors: delivery_course.errors.full_messages }, status: :unprocessable_entity
            end
        end
    end

    #--------------------------------------------------
    # 配送コース削除
    # DELETE /api/admin/delivery_courses/:id
    #--------------------------------------------------
    def destroy
        delivery_course = DeliveryCourse.find(params[:id])
        delivery_course.discard!
        render json: { success: true }, status: 200
    end

    #--------------------------------------------------
    #  配送コース検索
    #  GET /api/admin/delivery_courses/search
    #--------------------------------------------------
    def search
        delivery_courses = DeliveryCourse.preload(:delivery_orders).order(:created_at)
        delivery_courses = delivery_courses.where('delivery_courses.name LIKE ?', "%#{params[:name]}%") if params[:name].present?
        delivery_courses = delivery_courses.joins(delivery_locations: :client).where('clients.company_name LIKE ?', "%#{params[:client_company_name]}%").distinct if params[:client_company_name].present?

        delivery_courses_with_orders = []
        delivery_count = {}

        delivery_courses.each do |course|
            delivery_order_details = []
            course.delivery_orders.each do |order|
                delivery_order_details << {
                    id: order.id,
                    delivery_course_id: order.delivery_course_id,
                    delivery_location_id: order.delivery_location_id,
                    position: order.position,
                    discarded_at: order.discarded_at,
                    created_at: order.created_at,
                    updated_at: order.updated_at
                }
            end
    
            delivery_courses_with_orders << {
                id: course.id,
                name: course.name,
                discarded_at: course.discarded_at,
                created_at: course.created_at,
                updated_at: course.updated_at,
                driver_name: course.driver_name,
                delivery_location_count: delivery_order_details.count,
                delivery_orders: delivery_order_details
            }
    
            delivery_count[course.id] = delivery_order_details.count
        end

        render json: { delivery_courses: delivery_courses_with_orders }, status: 200
    end

    private
    def delivery_course_params
        params
        .require(:delivery_course)
        .permit(
            :name,
            :driver_name,
            delivery_orders_attributes: [:id, :delivery_location_id, :position]
        )
    end
end
