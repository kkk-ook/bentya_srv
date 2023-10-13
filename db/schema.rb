# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_10_10_024427) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "administrators", force: :cascade do |t|
    t.string "name", comment: "管理者名"
    t.string "email", comment: "メールアドレス"
    t.datetime "discarded_at"
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_administrators_on_confirmation_token", unique: true
    t.index ["email"], name: "index_administrators_on_email", unique: true
    t.index ["reset_password_token"], name: "index_administrators_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_administrators_on_uid_and_provider", unique: true
  end

  create_table "cards", force: :cascade do |t|
    t.bigint "user_id", null: false, comment: "顧客ID"
    t.string "name", comment: "カード名"
    t.string "stripe_payment_method_id", comment: "stripe支払方法ID"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_cards_on_user_id"
  end

  create_table "cart_details", force: :cascade do |t|
    t.bigint "cart_id", comment: "カートID"
    t.integer "count", comment: "個数"
    t.date "delivery_day", comment: "配送日"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_cart_details_on_cart_id"
  end

  create_table "carts", force: :cascade do |t|
    t.bigint "user_id", comment: "ユーザーID"
    t.bigint "product_id", comment: "商品ID"
    t.string "note", comment: "備考"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "price"
    t.index ["product_id"], name: "index_carts_on_product_id"
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", comment: "カテゴリ名"
    t.string "image", comment: "写真"
    t.string "icon", comment: "アイコン"
    t.string "description", comment: "説明"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "closing_time"
    t.boolean "is_same_day_reservation"
  end

  create_table "client_product_settings", force: :cascade do |t|
    t.bigint "product_id", comment: "商品ID"
    t.bigint "client_id", comment: "顧客ID"
    t.integer "price", comment: "顧客別販売価格"
    t.boolean "is_public", comment: "表示・非表示"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_client_product_settings_on_client_id"
    t.index ["product_id"], name: "index_client_product_settings_on_product_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "code", comment: "顧客コード"
    t.string "name", comment: "顧客名"
    t.string "company_name", comment: "会社名"
    t.string "postal_code", comment: "郵便番号"
    t.integer "prefecture", comment: "都道府県"
    t.string "address1", comment: "市区町村・番地"
    t.string "address2", comment: "建物名・部屋番号"
    t.string "tel", comment: "電話番号"
    t.string "staff_1", comment: "担当者1"
    t.string "staff_2", comment: "担当者2"
    t.string "staff_3", comment: "担当者3"
    t.string "memo", comment: "メモ"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delivery_courses", force: :cascade do |t|
    t.string "name", comment: "配送コース名"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "driver_name"
  end

  create_table "delivery_locations", force: :cascade do |t|
    t.bigint "client_id", comment: "顧客ID"
    t.string "name", comment: "納品場所名"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_delivery_locations_on_client_id"
  end

  create_table "delivery_orders", force: :cascade do |t|
    t.bigint "delivery_course_id", comment: "配送コースID"
    t.bigint "delivery_location_id", comment: "納品場所ID"
    t.integer "position", comment: "配送順"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_course_id"], name: "index_delivery_orders_on_delivery_course_id"
    t.index ["delivery_location_id"], name: "index_delivery_orders_on_delivery_location_id"
  end

  create_table "holidays", force: :cascade do |t|
    t.date "holiday_date", comment: "休日"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_details", force: :cascade do |t|
    t.bigint "order_id", comment: "注文ID"
    t.integer "count", comment: "個数"
    t.date "provision_on", comment: "お届け日"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_details_on_order_id"
  end

  create_table "order_headers", force: :cascade do |t|
    t.bigint "user_id", comment: "ユーザーID"
    t.integer "total_count", comment: "注文商品数"
    t.integer "total_price", comment: "合計金額"
    t.string "stripe_payment_intent_id", comment: "Stripe PaymentIntentID"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.string "cancel_time"
    t.index ["user_id"], name: "index_order_headers_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id", comment: "ユーザーID"
    t.bigint "product_id", comment: "商品ID"
    t.bigint "client_product_setting_id", comment: "顧客別商品設定ID"
    t.string "product_name", comment: "商品名"
    t.integer "order_count", comment: "注文商品数"
    t.integer "total_price", comment: "合計金額"
    t.string "stripe_payment_intent_id", comment: "Stripe PaymentIntentID"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "order_header_id", comment: "注文ID"
    t.index ["client_product_setting_id"], name: "index_orders_on_client_product_setting_id"
    t.index ["order_header_id"], name: "index_orders_on_order_header_id"
    t.index ["product_id"], name: "index_orders_on_product_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "product_details", force: :cascade do |t|
    t.bigint "product_id", comment: "商品ID"
    t.date "inventory_date", comment: "日付"
    t.integer "count", comment: "注文可能数"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_details_on_product_id"
  end

  create_table "product_images", force: :cascade do |t|
    t.bigint "product_id", comment: "商品ID"
    t.string "image", comment: "写真"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_images_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "category_id", comment: "カテゴリID"
    t.string "name", comment: "商品名"
    t.string "abbreviated_name", comment: "商品名の略語"
    t.string "catch_phrase", comment: "キャッチフレーズ"
    t.integer "display_price", comment: "表示価格"
    t.integer "common_selling_price", comment: "共通販売価格"
    t.boolean "is_public", comment: "表示・非表示"
    t.boolean "is_same_day_reservation", comment: "当日予約"
    t.date "period_start_on", comment: "期間限定開始日"
    t.date "period_end_on", comment: "期間限定終了日"
    t.string "description", comment: "商品説明"
    t.string "notes", comment: "注釈"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.index ["category_id"], name: "index_products_on_category_id"
  end

  create_table "slides", force: :cascade do |t|
    t.integer "position", comment: "順番"
    t.string "image", comment: "画像"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "terms", force: :cascade do |t|
    t.string "title", comment: "タイトル"
    t.text "body", comment: "本文"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.bigint "delivery_location_id", comment: "納品場所ID"
    t.string "user_code", comment: "ユーザーコード"
    t.string "last_name", comment: "姓"
    t.string "first_name", comment: "名"
    t.string "last_name_kana", comment: "セイ"
    t.string "first_name_kana", comment: "メイ"
    t.string "email", comment: "メールアドレス"
    t.string "tel", comment: "電話番号"
    t.string "stripe_customer_id", comment: "Stripe顧客ID"
    t.datetime "discarded_at"
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["delivery_location_id"], name: "index_users_on_delivery_location_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "cards", "users"
  add_foreign_key "cart_details", "carts"
  add_foreign_key "carts", "products"
  add_foreign_key "carts", "users"
  add_foreign_key "client_product_settings", "clients"
  add_foreign_key "client_product_settings", "products"
  add_foreign_key "delivery_locations", "clients"
  add_foreign_key "delivery_orders", "delivery_courses"
  add_foreign_key "delivery_orders", "delivery_locations"
  add_foreign_key "order_details", "orders"
  add_foreign_key "order_headers", "users"
  add_foreign_key "orders", "client_product_settings"
  add_foreign_key "orders", "order_headers"
  add_foreign_key "orders", "products"
  add_foreign_key "orders", "users"
  add_foreign_key "product_details", "products"
  add_foreign_key "product_images", "products"
  add_foreign_key "products", "categories"
  add_foreign_key "users", "delivery_locations"
end
