class Api::Front::HolidaysController < ApplicationController
    #--------------------------------------------------
    #  休日一覧
    #  GET /api/admin/holidays
    #--------------------------------------------------
    def index
        holidays = Holiday.order(:holiday_date)
        render json: { holidays: holidays }, status: 200
    end
end
