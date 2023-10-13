class Api::Admin::UsersController < ApplicationController
    before_action :authenticate_api_administrator!
    #--------------------------------------------------
    #  ユーザー一覧
    #  GET /api/admin/users
    #--------------------------------------------------
    def index
        params[:limit] ? limit = params[:limit].to_i : limit = nil
        params[:offset] ? offset = params[:offset].to_i : offset = 0
        users = User.order(:created_at)
        all_count = users.length
        users = users.limit(limit).offset(offset) if limit.present?
        render json: { all_count: all_count, users: users }, include: :delivery_location , status: 200
    end

    #--------------------------------------------------
    #  ユーザー登録
    #  POST /api/admin/users
    #--------------------------------------------------
    def create
        User.transaction do
            last_user = User.last
            user_id = last_user ? last_user.id + 1 : 1
            user_code = "U" + format("%05d", user_id)
            user = User.new(user_params)
            user.password = params[:password]
            user.skip_confirmation!
            if user.save
                render json: { success: true }, status: 200
            else
                render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
            end
        end
    end

    #--------------------------------------------------
    # ユーザー詳細
    # GET /api/admin/users/:id
    #--------------------------------------------------
    def show
        # ユーザーの所属している顧客、納品場所、注文内容を同時に渡す
        user = User.preload(:orders).find(params[:id])
        render json: { user: user }, include: [:client, :delivery_location, :orders], status: 200
    end

    #--------------------------------------------------
    #  ユーザー編集
    #  GET /api/admin/users/:id/edit
    #--------------------------------------------------
    def edit
        user = User.find(params[:id])
        render json: { user: user }, status: 200
    end

    #--------------------------------------------------
    #  ユーザー編集
    #  PUT /api/admin/users/:id
    #--------------------------------------------------
    def update
        User.transaction do
            user = User.find(params[:id])
            user.password = params[:password]
            if user.update(user_params)
                render json: { success: true }, status: 200
            else
                render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
            end
        end
    end

    #--------------------------------------------------
    # ユーザー削除
    # DELETE /api/admin/users/:id
    #--------------------------------------------------
    def destroy
        user = User.find(params[:id])
        user.discard!
        render json: { success: true }, status: 200
    end

    #--------------------------------------------------
    #  ユーザー検索
    #  GET /api/admin/users/search
    #--------------------------------------------------
    def search
        users = User.order('users.created_at')
        users = users.joins(delivery_location: :client).where('clients.company_name LIKE ?', "%#{params[:client_company_name]}%") if params[:client_company_name].present?
        users = users.where('last_name LIKE ? OR first_name LIKE ? OR last_name_kana LIKE ? OR first_name_kana LIKE ?', "%#{params[:name]}%", "%#{params[:name]}%", "%#{params[:name]}%", "%#{params[:name]}%") if params[:name].present?
        users = users.where(user_code: params[:user_code]) if params[:user_code].present?
        users = users.where('email LIKE ?', "%#{params[:email]}%") if params[:email].present?
        if params[:created_at_1].present?
            created_at_1 = Date.parse(params[:created_at_1])
            users = users.where('users.created_at >= ?', created_at_1.to_s)
        end
        if params[:created_at_2].present?
            created_at_2 = Date.parse(params[:created_at_2]) + 1.day
            users = users.where('users.created_at <= ?', created_at_2.to_s)
        end
    
        response = {
            created_at_1: params[:created_at_1],
            created_at_2: params[:created_at_2],
            users: users
        }
        
        render json: response, include: :delivery_location, status: 200
    end

    private
    def user_params
        params
        .require(:user)
        .permit(:delivery_location_id, :user_code, :last_name, :first_name, :last_name_kana, :first_name_kana, :email, :tel, :password, :password_confirmation)
    end
end
