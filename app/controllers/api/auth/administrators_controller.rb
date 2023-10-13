class Api::Auth::AdministratorsController < DeviseTokenAuth::RegistrationsController
    before_action :authenticate_api_administrator!, only: [:edit, :update, :destroy]
    #--------------------------------------------------
    # 管理者編集
    # GET /api/admin_auth/edit
    #--------------------------------------------------
    def edit
        render json: { Administrator: get_administrator_hash}
    end

    private
    def sign_up_params
        params.permit(:name, :email, :password)
    end

    def account_update_params
        params.permit(:name, :email, :password)
    end

    def get_administrator_hash
        {
            id: @resource.id,
            name: @resource.name,
            email: @resource.email
        }
    end
end
