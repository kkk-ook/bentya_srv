class Api::Front::ConfirmationsController < DeviseTokenAuth::ConfirmationsController
    #--------------------------------------------------
    # 顧客確認(メール再送)
    #--------------------------------------------------
    def create
        return render_create_error_missing_email if resource_params[:email].blank?

        @email = get_case_insensitive_field_from_resource_params(:email)

        @resource = resource_class.dta_find_by(uid: @email, provider: provider)

        # ここから変更↓　メール変更の確認メール再送に対応
        unless @resource
            @resource = resource_class.dta_find_by(unconfirmed_email: @email, provider: provider)
            return render_not_found_error if @resource.blank?
        end
        # return render_not_found_error unless @resource
        # ここまで変更↑

        # ここから追加↓　認証済の場合は
        if @resource.confirmed_at.present? && @resource.unconfirmed_email.blank?
            return render json: {
                    success: false,
                    errors: ["メールアドレスは認証済です"]
            }, status: 400
        end
        # ここまで追加↑

        @resource.send_confirmation_instructions({
                                                        redirect_url: redirect_url,
                                                        client_config: resource_params[:config_name]
                                                })

        return render_create_success
    end

end
