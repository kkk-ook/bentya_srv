class Api::Front::SlidesController < ApplicationController
    #--------------------------------------------------
    # スライド一覧
    # GET /api/customer/slides
    #--------------------------------------------------
    def index
        slides = Slide.all.sorted.select(:id, :image)
        render json: { slides: slides }
    end

    rescue_from Exception do |exception|
        render json: { errors: [exception] }, status: 500
    end
end
