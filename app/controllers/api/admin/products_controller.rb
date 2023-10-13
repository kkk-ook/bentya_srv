class Api::Admin::ProductsController < ApplicationController
    before_action :authenticate_api_administrator!
    #--------------------------------------------------
    #  商品一覧
    #  GET /api/admin/products
    #--------------------------------------------------
    def index
        products = Product.preload(:product_images).order(position: :asc)
        render json: { products: products }, include: :product_images, status: 200
    end

    #--------------------------------------------------
    #  商品登録
    #  POST /api/admin/products
    #--------------------------------------------------
    def create
        Product.transaction do
            product = Product.new(product_params)
            if product.save
                # 顧客の数だけ顧客別商品設定を作成
                Client.all.each do |client|
                    client.client_product_settings.create!(
                        product_id: product.id,
                        is_public: product_params[:is_public],
                        price: product_params[:common_selling_price]
                    )
                end
                render json: { product_id: product.id }, status: 200
            else
                render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
            end
        end
    end

    #--------------------------------------------------
    #  商品編集
    #  GET /api/admin/products/:id/edit
    #--------------------------------------------------
    def edit
        product = Product.preload(:product_images).find(params[:id])
        render json: { product: product }, include: :product_images, status: 200
    end

    #--------------------------------------------------
    #  商品編集
    #  PUT /api/admin/products/:id
    #--------------------------------------------------
    def update
        Product.transaction do
            product = Product.find(params[:id])
            if product.update(product_params)
                render json: { success: true }, status: 200
            else
                render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
            end
        end
    end

    #--------------------------------------------------
    # 商品削除
    # DELETE /api/admin/products/:id
    #--------------------------------------------------
    def destroy
        product = Product.find(params[:id])
        product.discard!
        render json: { success: true }, status: 200
    end

    #--------------------------------------------------
    #  商品検索
    #  GET /api/admin/products/search
    #--------------------------------------------------
    def search
        products = Product.preload(:product_images).order(position: :asc)
        products = products.where('name LIKE ?', "%#{params[:name]}%") if params[:name].present?
        products = products.where(code: params[:code]) if params[:code].present?
        products = products.where(category_id: params[:category_id]) if params[:category_id].present?
        products = products.where('common_selling_price >= ?', params[:low_price]) if params[:low_price].present?
        products = products.where('common_selling_price <= ?', params[:high_price]) if params[:high_price].present?
        if params[:created_at_1].present?
            created_at_1 = Date.parse(params[:created_at_1])
            products = products.where('created_at >= ?', created_at_1.to_s)
        end
        if params[:created_at_2].present?
            created_at_2 = Date.parse(params[:created_at_2]) + 1.day
            products = products.where('created_at <= ?', created_at_2.to_s)
        end
        if params[:is_public].present?
            if ["true", "false"].include?(params[:is_public].downcase)
                is_public_value = params[:is_public].downcase == "true"
                products = products.where(is_public: is_public_value)
            elsif params[:is_public].downcase == "null"
                products = products.where.not(is_public: nil)
            end
        end
        

        response = {
            created_at_1: created_at_1,
            created_at_2: created_at_2,
            products: products
        }

        render json: response, include: :product_images, status: 200
    end

    #--------------------------------------------------
    # 商品の順番の並べ替え
    # POST /admin/products/sort
    #--------------------------------------------------
    def sort
        # 送信された並び順の情報を取得
        product_ids = params[:product_ids]
    
        # 新しい並び順に基づいてpositionを更新
        product_ids.each_with_index do |id, index|
            Product.find(id).update!(position: index + 1)
        end
    
        render json: { success: true }, status: 200
    end


    private
    def product_params
        params
        .require(:product)
        .permit(
            :category_id, :name, :abbreviated_name, :catch_phrase, :display_price, :common_selling_price, :is_public, :period_start_on, :period_end_on, :description, :notes, :position,
            product_images_attributes: [:id, :image]
        )
    end
end