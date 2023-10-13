class Api::Admin::SlidesController < ApplicationController
    before_action :authenticate_api_administrator!
    #--------------------------------------------------
    # スライド編集
    # GET /api/admin/slides
    #--------------------------------------------------
    def edit
        slides = Slide.all.sorted.select(:id, :image)
        render json: { slides: slides }
    end

    #--------------------------------------------------
    # スライド編集
    # PATCH/PUT /api/admin/slides
    #--------------------------------------------------
    def update
        Slide.transaction do
            slides_params.each do |slide_params|
                slide = Slide.find(slide_params[:id])
                slide.image = slide_params[:image]
                slide.save!
            end
        end
        slides = Slide.all.sorted.select(:id, :image)
        render json: { slides: slides }
    end

    private

    def slides_params
        params.require(:slides).map { |s| s.permit(:id, :image) }
    end

    rescue_from Exception do |exception|
        render json: { errors: [exception] }, status: 500
    end
end
