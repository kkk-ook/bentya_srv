class StripeController < ApplicationController
    skip_before_action :verify_authenticity_token

    def order_success
        payload = request.body.read
        sig_header = request.env['HTTP_STRIPE_SIGNATURE']
        endpoint_secret = Rails.application.credentials.dig(:stripe, :endpoint_secret)
        puts params.inspect
        event = nil

        begin
            event = Stripe::Webhook.construct_event(
                payload, sig_header, endpoint_secret
            )

        rescue JSON::ParserError, Stripe::SignatureVerificationError => e
            Rails.logger.debug e
            render json: { status: 400 }, status: 400 
            return
        end

        #--------------------------------------------------
        # 注文ステータス
        #--------------------------------------------------
        session = event.data.object
        order_header = OrderHeader.find(session.client_reference_id)

        # 注文が成功した場合
        if event['type'] == 'checkout.session.completed'
            order_header.update(status: 'success', stripe_payment_intent_id: session.payment_intent)
        end
        # 注文が失敗した場合
        if event['type'] == 'checkout.session.async_payment_failed'
            order_header.update(status: 'failed')
        end

        #--------------------------------------------------
        # カート削除
        #--------------------------------------------------
        carts = Cart.where(user_id: order_header.user_id)
        carts.each do |cart|
            cart.discard
        end

        #--------------------------------------------------	
        # メール送信
        #-------------------------------------------------- 
        begin
            UserMailer.order_received(order_header, order_header.orders).deliver_now
        rescue => e
            Rails.logger.error "メール送信失敗: #{e.message}"
        end

        render json: { status: 200 }, status: 200 
    end

end
