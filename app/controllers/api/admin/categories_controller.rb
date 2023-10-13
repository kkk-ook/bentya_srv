class Api::Admin::CategoriesController < ApplicationController
    before_action :authenticate_api_administrator!
    #--------------------------------------------------
    #  カテゴリ一覧
    #  GET /api/admin/categories
    #--------------------------------------------------
    def index
        categories = Category.order(:created_at)
        render json: { categories: categories }, status: 200
    end

    #--------------------------------------------------
    #  カテゴリ登録
    #  POST /api/admin/categories
    #--------------------------------------------------
    def create
        Category.transaction do
            category = Category.new(category_params)
            if category.save
                render json: { success: true }, status: 200
            else
                render json: { errors: ["カテゴリーの登録に失敗しました"] }, status: 422
            end
        end
    end

    #--------------------------------------------------
    #  カテゴリ編集
    #  GET /api/admin/categories/:id/edit
    #--------------------------------------------------
    def edit
        category = Category.find(params[:id])
        render json: { category: category }, status: 200
    end

    #--------------------------------------------------
    #  カテゴリ編集
    #  PUT /api/admin/categories/:id
    #--------------------------------------------------
    def update
        Category.transaction do
            category = Category.find(params[:id])
            if category.update(category_params)
                render json: { success: true }, status: 200
            else
                render json: { errors: ["カテゴリーの編集に失敗しました"] }, status: 422
            end
        end
    end

    #--------------------------------------------------
    # カテゴリ削除
    # DELETE /api/admin/categories/:id
    #--------------------------------------------------
    def destroy
        category = Category.find(params[:id])
        category.discard!
        render json: { success: true }, status: 200
    end

    private
    def category_params
        params
        .require(:category)
        .permit(:name, :image, :icon, :is_same_day_reservation, :closing_time, :description)
    end
end
