desc "This task is called by the Heroku scheduler add-on"
task test_scheduler: :environment do
    puts "scheduler test"
    puts "it works."
end

require "date"
#--------------------------------------------------
# 期間限定商品表示切り替え
#--------------------------------------------------
desc "日付が変わるごとに期間限定商品の期限を確認"
task public_switch: :environment do
    products = Product.where(is_public: true).where.not(period_end_on: nil)
    today = Date.today.to_s
    products.each do |product|
        if product.period_end_on.to_s < today
            product.update(is_public: false)
        end
    end
    puts "更新"
end

#--------------------------------------------------
# 月初に翌々月の定休日登録
#--------------------------------------------------
desc "毎月一日に翌々月の土日をholidayに登録"
task create_holiday: :environment do
    today = Date.today
    if today.day == 1
        next_next_month = today + 2.month
        holidays = []
        (next_next_month..next_next_month.end_of_month).each do |date|
            holidays << date if date.saturday? || date.sunday?
        end

        holidays.each do |holiday|
            Holiday.create(holiday_date: holiday)
        end
    end
end

#--------------------------------------------------
# 0時にログアウト
#--------------------------------------------------
desc "毎日0時になったら全ユーザーをログアウト"
task logout_user: :environment do

    # tokensを削除してログアウト
    User.all.each do |user|
        user.update(tokens: nil)
    end
    puts "全ユーザーをログアウトさせました。"

    # カート削除
    Cart.all.each do |cart|
        cart.discard!
    end
    puts "全ユーザーのカートを削除しました。"

end