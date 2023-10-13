class Api::Admin::HolidaysController < ApplicationController
    #--------------------------------------------------
    #  休日一覧
    #  GET /api/admin/holidays
    #--------------------------------------------------
    def index
        holidays = Holiday.order(:holiday_date)
        render json: { holidays: holidays }, status: 200
    end

    #--------------------------------------------------
    #  休日登録
    #  GET /api/admin/holidays
    #--------------------------------------------------
    def create
        Holiday.transaction do
            holiday = Holiday.new(holiday_params)
            if holiday.save
                render json: { success: true }, status: 200
            else
                render json: { errors: holiday.errors.full_messages }, status: :unprocessable_entity
            end
        end
    end

    #--------------------------------------------------
    # 休日削除
    # DELETE /api/admin/holidays/:id
    #--------------------------------------------------
    def destroy
        product = Holiday.find(params[:id])
        product.destroy!
        render json: { success: true }, status: 200
    end

    private
    def holiday_params
        params
        .require(:holiday)
        .permit(:holiday_date)
    end
end
