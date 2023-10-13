class ApplicationController < ActionController::Base
    include DeviseTokenAuth::Concerns::SetUserByToken
    skip_before_action :verify_authenticity_token, if: :check_origin

    def check_origin
        puts "Request Referer: #{request.headers['Referer']}"
        return true if Rails.env.development?
        if request.headers['Referer'].present?
            if request.headers['Referer'].include?("https://sennnari-front-970c8fdd8060.herokuapp.com") ||
                request.headers['Referer'].include?("https://sennari-app.com")
                return true
            else
                return false
            end
        else
            return false
        end
    end


    #--------------------------------------------------
    # 商品を購入可能か？
    #--------------------------------------------------
    def purchaseable?(cart_params, product)
        #--------------------------------------------------
        # 変数の設定
        #--------------------------------------------------
        if cart_params[:datetime_got_product].present?
            target_datetime = Time.parse(cart_params[:datetime_got_product])
        elsif cart_params[:updated_at].present?
            target_datetime = Time.parse(cart_params[:updated_at])
        end

        #--------------------------------------------------
        # チェック処理
        #--------------------------------------------------
        # 非公開の場合、productがnilなので１番にチェックすること!!!
        # 公開/非公開、商品更新をチェック
        if product.blank? || product.updated_at > target_datetime
            return false, "商品情報が更新されたため"
        end

        # 期間限定のチェック
        if product.period_start_on.present? && product.period_start_on > Date.today
            return false, "購入可能期間外のため"
        end
        if product.period_end_on.present? && product.period_end_on < Date.today
            return false, "購入可能期間外のため"
        end

        return true, nil
    end

end