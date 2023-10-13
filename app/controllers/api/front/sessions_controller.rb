class Api::Front::SessionsController < DeviseTokenAuth::SessionsController
    def destroy
        # ログアウト時にカートから商品削除
        if @resource
            @resource.carts.each do |cart|
                cart.discard
            end
        end

        super
    end
end