class Api::Front::TodaysController < ApplicationController
    def today
        today = Date.today

        render json: {today: today}, status: 200
    end
end
