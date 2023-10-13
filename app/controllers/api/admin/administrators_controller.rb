class Api::Admin::AdministratorsController < ApplicationController
    before_action :authenticate_api_administrator!
    #--------------------------------------------------
    #  管理者一覧
    #  GET /api/admin/administrators
    #--------------------------------------------------
    def index
        administrators = Administrator.order(:created_at)
        render json: { administrators: administrators }, status: 200
    end

    #--------------------------------------------------
    #  管理者情報
    #  GET /api/admin/administrators/detail
    #--------------------------------------------------
    def detail
        administrator = Administrator.find(@resource.id)
        render json: { administrator: administrator }, status: 200
    end

    #--------------------------------------------------
    #  管理者登録
    #  POST /api/admin/administrators
    #--------------------------------------------------
    def create
        Administrator.transaction do
            administrator = Administrator.new(administrator_params)
            administrator.password = params[:password]
            if administrator.save
                render json: { success: true }, status: 200
            else
                render json: { errors: administrator.errors.full_messages }, status: :unprocessable_entity
            end
        end
    end

    #--------------------------------------------------
    #  管理者編集
    #  GET /api/admin/administrators/:id/edit
    #--------------------------------------------------
    def edit
        administrator = Administrator.find(params[:id])
        render json: { administrator: administrator }, status: 200
    end

    #--------------------------------------------------
    #  管理者編集
    #  PUT /api/admin/administrators/:id
    #--------------------------------------------------
    def update
        Administrator.transaction do
            administrator = Administrator.find(params[:id])
            administrator.password = params[:password]
            if administrator.update(administrator_params)
                render json: { success: true }, status: 200
            else
                render json: { errors: administrator.errors.full_messages }, status: :unprocessable_entity
            end
        end
    end

    #--------------------------------------------------
    # 管理者削除
    # DELETE /api/admin/administrators/:id
    #--------------------------------------------------
    def destroy
        administrator = Administrator.find(params[:id])

        logged_in_admin = Administrator.find(@resource.id)

        if logged_in_admin == administrator
            render json: { errors: ["自分自身を削除することはできません"] }, status: 400
            return
        end

        administrator.discard!

        render json: { success: true }, status: 200
    end


    private
    def administrator_params
        params
        .require(:administrator)
        .permit(:name, :email, :password, :password_confirmation)
    end
end