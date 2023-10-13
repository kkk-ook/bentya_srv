class Api::Front::UsersController < ApplicationController
    before_action :authenticate_api_user!

    #--------------------------------------------------
    # ユーザー詳細
    # GET /api/front/users
    #--------------------------------------------------
    def index
        user = User.preload(:order_headers).find(@resource.id)
        render json: { user: user }, include: [:client, :delivery_location, :order_headers], status: 200
    end

end