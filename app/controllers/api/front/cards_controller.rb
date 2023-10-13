class Api::Front::CardsController < ApplicationController
    before_action :authenticate_api_user!
    #--------------------------------------------------
    # カード情報
    # GET /api/front/cards
    #--------------------------------------------------
    def index
        stripe_customer_id = params[:stripe_customer_id]
        customer = Stripe::Customer.retrieve(stripe_customer_id)
        default_source = customer.default_source
        
        render json: { user: default_source }, status: 200
    end

    #--------------------------------------------------
    # カード新規登録
    # POST /api/front/cards
    #--------------------------------------------------
    def create
        customer_id = @resource.stripe_customer_id # 顧客ID
        puts "----------"
        puts customer_id.inspect
        payment_method_id = params[:card][:payment_method_id] # フロントから
    
        # 支払い方法を顧客に関連付けます。
        payment_method = Stripe::PaymentMethod.attach(
            payment_method_id,
            {customer: customer_id}
        )
        card_data = get_card_hash(payment_method)
        render json: { card: card_data }
    end

    def get_card_hash(payment_method)
        {
                name: payment_method.present? ? payment_method.billing_details.name : nil,
                brand: payment_method.present? ? payment_method.card.brand : nil,
                exp_month: payment_method.present? ? payment_method.card.exp_month : nil,
                exp_year: payment_method.present? ? payment_method.card.exp_year : nil,
                last4: payment_method.present? ? payment_method.card.last4 : nil,
        }
    end
end