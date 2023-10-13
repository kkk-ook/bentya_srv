class UserMailer < ApplicationMailer
    default from: Constants::SEND_SHOP_EMAIL
    #--------------------------------------------------
    # メール送信デバッグ用
    #--------------------------------------------------
    def mail_debug(email)
        @email = email
        mail(
                subject: "【テスト】メール送受信の確認",
                to: email
        ) do |format|
            format.text
        end
    end

    #--------------------------------------------------
    # 注文受付時
    #--------------------------------------------------
    def order_received(order_header, orders)
        @order_header = order_header
        @orders = orders
        @resource = order_header.user
        mail(
                subject: "【千成】ご注文ありがとうございます",
                to: @resource.email,
        ) do |format|
            format.text
        end
    end

end