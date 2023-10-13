class Api::Admin::TermsController < ApplicationController
    before_action :authenticate_api_administrator!
    #--------------------------------------------------
    # 規約編集
    # GET /api/admin/terms/:id/edit
    #--------------------------------------------------
    def edit
        term = Term.find(params[:id])

        render json: {term: term}
    end

    #--------------------------------------------------
    # 規約編集
    # PATCH /api/admin/terms/:id/edit
    #--------------------------------------------------
    def update
        term = Term.find(params[:id])
        term = term.update!(term_params)

        render json: {term: term}
    end


    private
    def term_params
        params
        .require(:term)
        .permit(:body)
    end
end
