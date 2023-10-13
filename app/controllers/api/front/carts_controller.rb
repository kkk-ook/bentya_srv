class Api::Front::CartsController < ApplicationController
    before_action :authenticate_api_user!
    #--------------------------------------------------
    # カート一覧取得
    # GET /api/front/carts
    #--------------------------------------------------
    def index
        carts = @resource.carts.preload(:product)

        #--------------------------------------------------
        # カートから商品削除
        #--------------------------------------------------
        carts.each do |cart|
            # カート追加後に商品が削除されていた場合
            if cart.product.blank?
                cart.discard
                break
            end
            # カート追加後に商品が更新されていた場合
            if cart.created_at < cart.product.updated_at
                cart.discard
                break
            end
            # カート追加後に商品が非公開となった場合
            unless cart.product.is_public?
                cart.discard
                break
            end
        end

        carts = @resource.carts.preload(:cart_details, product: :category).order(created_at: :asc)

        render json: { carts: carts }, include: [:cart_details, {product: {include: [:product_images]}}], status: 200
    end

    #--------------------------------------------------
    # カート新規登録(すでにレコードがある場合、数を加算する)
    # POST /api/front/carts
    #--------------------------------------------------
    def create
        product = Product.publish.find_by(id: cart_params[:product_id])
        is_purchaseable, error_message = purchaseable?(params[:cart], product)
        
        unless is_purchaseable
            raise ActionController::BadRequest, "#{error_message}、カートに追加できません。"
        end

        cart = @resource.carts.find_by(product_id: cart_params[:product_id])
        Cart.transaction do
            #--------------------------------------------------
            # カート(Cart)登録or更新
            #--------------------------------------------------
            if cart.blank?
                cart = @resource.carts.build(cart_params)
            end
            cart.save!

            #--------------------------------------------------
            # カート詳細(CartDetail)更新
            #--------------------------------------------------
            update_cart_details(cart, true)
        end
        render json: { cart: cart }, include: [:cart_details, {product: {include: [:product_images]}}], status: 200
    end

    #--------------------------------------------------
    # カート変更(countを更新)
    # PATCH/PUT /api/front/carts/:id
    #--------------------------------------------------
    def update
        cart = @resource.carts.find(params[:id])

        if cart.blank?
            render json: { errors: ["対象の商品が存在しません。"] }, status: 400
            return
        end
        #--------------------------------------------------
        # カート詳細(CartDetail)更新
        #--------------------------------------------------
        update_cart_details(cart, false)

        render json: { cart: cart }, include: [:cart_details, {product: {include: [:product_images]}}], status: 200
    end

    #--------------------------------------------------
    # カート削除
    # DELETE /api/front/carts/:id
    #--------------------------------------------------
    def destroy
        cart = @resource.carts.find_by(id: params[:id])
        if cart.blank?
            render json: { errors: ["対象の商品が存在しません"] }, status: 400
            return
        end

        cart.discard!

        render json: { success: true }
    end


    private
    def cart_params
        params.require(:cart)
        .permit(:product_id, :price, :datetime_got_product)
    end

    def cart_update_params
        params.require(:cart)
        .permit(:count, :note)
    end

    # カート詳細更新
    def update_cart_details(cart, is_addition)
        cart_details = cart.cart_details
        params[:cart][:cart_details].each do |cart_detail_params|
            cart_detail = cart_details.find_by(delivery_day: cart_detail_params[:delivery_day])
            if cart_detail.blank?
                cart_detail = CartDetail.new()
                cart_detail.cart_id = cart.id
                cart_detail.delivery_day = cart_detail_params[:delivery_day]
            end
            if is_addition
                cart_detail.count = cart_detail.count + cart_detail_params[:count]
            else
                cart_detail.count = cart_detail_params[:count]
            end
            cart_detail.save!
        end
    end

    rescue_from Exception do |exception|
        exception.class.name == "ActionController::BadRequest" ? status = 400 : status = 500
        puts "*** error(user/carts) *** status=#{status} login_customer_id=#{@resource.id} exception=#{exception}"
        render json: { errors: [exception] }, status: status
    end
end