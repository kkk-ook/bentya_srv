class Api::Admin::ProductImagesController < ApplicationController
    before_action :authenticate_api_administrator!
    #--------------------------------------------------
    #  商品写真登録
    #  POST /api/admin/product_images
    #--------------------------------------------------
    def create
        ProductImage.transaction do
            product_image = ProductImage.new
            product_image.product_id = params[:product_id]
            product_image.image = params[:image]
            if product_image.save
                render json: { success: true }, status: 200
            else
                render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
            end
        end
    end

    #--------------------------------------------------
    #  商品写真編集
    #  PUT /api/admin/product_images
    #--------------------------------------------------
    def update
        ProductImage.transaction do
            product_image = ProductImage.find(params[:id])
            if product_image.update(image: params[:image])
                render json: { success: true }, status: 200
            else
                render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
            end
        end
    end

    #--------------------------------------------------
    # 商品写真削除
    # DELETE /api/admin/product_images/:id
    #--------------------------------------------------
    def destroy
        product_image = ProductImage.find(params[:id])
        product_image.discard!
        render json: { success: true }, status: 200
    end
end
