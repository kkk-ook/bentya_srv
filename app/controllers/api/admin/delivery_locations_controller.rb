class Api::Admin::DeliveryLocationsController < ApplicationController
    #--------------------------------------------------
    # 配送順並べ替え
    # POST /admin/delivery_locations/replacement
    #--------------------------------------------------
    def replacement
        delivery_location_from = DeliveryLocation.find(params[:delivery_location_from][:id])
        delivery_location_to = DeliveryLocation.find(params[:delivery_location_to][:id])
        puts delivery_location_from.inspect
        puts delivery_location_to.inspect

        if delivery_location_from.position != params[:delivery_location_from][:position] || delivery_location_to.position != params[:delivery_location_to][:position]
            render json: { errors: ["再実行して下さい"] }, status: 400
            return
        end

        if delivery_location_from.position < delivery_location_to.position
            # 前→後 移動の場合
            count = delivery_location_to.position - delivery_location_from.position
            count.times { delivery_location_from.move_lower }
        else
            # 後→前 移動の場合
            count = delivery_location_from.position - delivery_location_to.position
            count.times { delivery_location_from.move_higher }
        end
        render json: { success: true }, status: 200
    end
end


