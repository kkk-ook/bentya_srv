class Api::Auth::RegistrationsController < DeviseTokenAuth::RegistrationsController
    before_action :authenticate_api_user!, only: [:edit, :update, :destroy]
    #--------------------------------------------------
    # ユーザー新規登録
    # POST /api/auth
    #--------------------------------------------------
    def create
        @resource = User.new(sign_up_params)
        if @resource.save
            token = @resource.confirmation_token
            DeviseMailer.confirmation_instructions(@resource, token).deliver_now
            render json: { success: true }, status: 200
        else
            render json: { errors: @resource.errors.full_messages }, status: :unprocessable_entity
        end
    end
    
    #--------------------------------------------------
    # ユーザー編集
    # GET /api/auth/edit
    #--------------------------------------------------
    def edit
        render json: { user: get_user_hash}
    end

    private

    def sign_up_params
        params.permit(:delivery_location_id, :last_name, :first_name, :last_name_kana, :first_name_kana, :email, :tel, :password)
    end

    def account_update_params
        params.permit(:last_name, :first_name, :last_name_kana, :first_name_kana, :email, :tel, :postal_code, :prefecture, :address1, :address2, :password)
    end

    def get_user_hash
        {
            id: @resource.id,
            delivery_location_id: @resource.delivery_location_id,
            last_name: @resource.last_name,
            first_name: @resource.first_name,
            last_name_kana: @resource.last_name_kana,
            first_name_kana: @resource.first_name_kana,
            email: @resource.email,
            tel: @resource.tel
        }
    end
end
