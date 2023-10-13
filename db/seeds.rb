# unless Rails.env.production?
#     client = Client.find_or_create_by!(
#         code: "0001",
#         name: "（株）uncode",
#         company_name: "株式会社uncode",
#         postal_code: "7300812",
#         prefecture: 34,
#         address1: "広島市中区加古町13-2",
#         address2: "2F",
#         tel: "082-533-6961",
#         staff_1: "山田",
#         staff_2: "佐藤",
#         staff_3: "高野",
#         memo: "従業員数6人"
#     )

#     DeliveryCourse.find_or_create_by!(
#         name: "中区ルート",
#         driver_name: "ドライバー中太郎"
#     )

#     delivery_location = DeliveryLocation.find_or_create_by!(
#         client_id: 1,
#         name: "サーバーサイド部門"
#     )
#     delivery_location = DeliveryLocation.find_or_create_by!(
#         client_id: 1,
#         name: "フロントエンド部門",
#     )

#     DeliveryOrder.find_or_create_by!(
#         delivery_course_id: 1,
#         delivery_location_id: delivery_location.id, # 納品場所IDを指定
#         position: 1
#     )

#     category = Category.find_or_create_by!(
#         name: "定番",
#         image: "",
#         icon: "",
#         description: "毎日たのめる定番のお弁当です。"
#     )

#     product = Product.find_or_create_by!(
#         category_id: category.id,
#         name: "唐揚げ弁当",
#         abbreviated_name: "定唐",
#         catch_phrase: "みんな大好き唐揚げ5個入り",
#         display_price: 500,
#         common_selling_price: 450,
#         is_public: true,
#         is_same_day_reservation: false,
#         period_start_on: "",
#         period_end_on: "",
#         description: "唐揚げ5個、副菜が2種類入っています。",
#         notes: "この商品は当日の注文が可能です。"
#     )
    
#     ProductImage.find_or_create_by!(
#         product_id: product.id,
#         image: ""
#     )
    
#     if User.all.blank?
#         User.create!(
#             delivery_location_id: 1,
#             user_code: "U00001",
#             last_name: "田中",
#             first_name: "太郎",
#             last_name_kana: "タナカ",
#             first_name_kana: "タロウ",
#             email: "info@uncode.co.jp",
#             tel: "0825336961",
#             password: "secret49",
#             password_confirmation: "secret49"
#         )
#     end

#     client_product_setting = ClientProductSetting.find_or_create_by!(
#         product_id: product.id,
#         client_id: client.id,
#         price: 400,
#         is_public: true
#     )

#     Order.find_or_create_by!(
#         user_id: 1,
#         product_id: product.id,
#         client_product_setting_id: client_product_setting.id,
#         product_name: "唐揚げ弁当",
#         order_count: 1,
#         total_price: 400,
#     )

#     OrderDetail.find_or_create_by!(
#         order_id: 1,
#         count: 1,
#         provision_on: Date.today
#     )

#     holiday1 = Date.today.next_occurring(:saturday)
#     Holiday.find_or_create_by!(
#         holiday_date: holiday1
#     )

#     holiday2 = Date.today.next_occurring(:sunday)
#     Holiday.find_or_create_by!(
#         holiday_date: holiday2
#     )
# end

admins= [
    { name: '管理者太郎', email: 'info@uncode.co.jp', password: 'secret49', password_confirmation: "secret49", confirmed_at: Time.now},
    { name: '管理者三郎', email: 'info3@uncode.co.jp', password: 'secret49', password_confirmation: "secret49", confirmed_at: Time.now}
]
admins.each do |record|
    Administrator.create!(record) unless Administrator.find_by(email: record[:email])
end

# if Slide.all.blank?
#     Slide.create(position: 1)
#     Slide.create(position: 2)
#     Slide.create(position: 3)
# end

# if Term.all.blank?
#     Term.create(title: "特定商取引法に基づく表記")
#     Term.create(title: "プライバシーポリシー")
#     Term.create(title: "利用規約")
#     Term.create(title: "重要なお知らせ")
#     Term.create(title: "おすすめ商品の説明")
# end