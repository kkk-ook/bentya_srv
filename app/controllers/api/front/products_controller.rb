class Api::Front::ProductsController < ApplicationController
    before_action :authenticate_api_user!
    #--------------------------------------------------
    #  注文可能商品一覧
    #  GET /api/front/products
    #--------------------------------------------------
    def index
        # ユーザーが属する顧客の商品設定と商品自体で設定されている表示設定がどちらも「true」のものを取得
        client = @resource.client
        product_ids = ClientProductSetting.where(client_id: client.id, is_public: true).map(&:product_id)
        categories = Category.includes(:products).where(products: { id: product_ids, is_public: true }).order('products.position ASC')
        render json: { categories: categories }, include: {products: {include: [:product_images, :client_product_settings]}}, status: 200
    end
    

    #--------------------------------------------------
    #  注文可能商品詳細
    #  GET /api/front/products/:id
    #--------------------------------------------------
    def show
        product = Product.find(params[:id])
        holidays = Holiday.all
        
        today = Time.now
        purchasable, _ = purchaseable?(product)

        render json: {
            product: product,
            purchaseable: purchasable,
            today: today
        }, include: [:category, :product_images, :client_product_settings], status: 200
    end



    def purchaseable?(product)
        #--------------------------------------------------
        # チェック処理
        #--------------------------------------------------
        closing_hour = Time.parse(product.category.closing_time).hour

        current_hour = Time.now.hour

        # 当日予約のチェック
        if product.category.is_same_day_reservation
            if current_hour >= closing_hour
                return false, "当日予約の締め切り時刻を過ぎています"
            end
        else
            # 前日予約のチェック
            if current_hour >= closing_hour
                return false, "前日の締め切り時刻を過ぎています"
            end
        end

        return true, nil
    end
end