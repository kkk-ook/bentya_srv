class Api::Front::TermsController < ApplicationController
    #--------------------------------------------------
    # 規約編集
    # GET /api/admin/terms/:id/edit
    #--------------------------------------------------
    def show
        term = Term.select(:id, :title, :body).find_by(id: params[:id])
        render json: { term: term }
    end
end
