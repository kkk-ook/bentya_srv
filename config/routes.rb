Rails.application.routes.draw do
    namespace :api do
        mount_devise_token_auth_for 'User', at: 'auth', controllers: {
            registrations: 'api/auth/registrations',
            confirmations: 'api/front/confirmations',
            sessions: 'api/front/sessions',
        }
        namespace :front do
        # ユーザー
        resources :users
        # オーダー
        resources :orders
        # 商品
        resources :products
        # 休日
        resources :holidays
        # スライド
        resources :slides
        # 規約
        resources :terms
        # カート
        resources :carts
        # 顧客
        resources :clients
        # カード
        resources :cards
        # 今日の日付
        get "/today", to: "todays#today"
        end

        mount_devise_token_auth_for 'Administrator', at: 'admin_auth', controllers: {
            registrations: 'api/auth/administrators'
        }
        namespace :admin do
            # 管理者
            resources :administrators do
                collection do
                get "detail"
                end
            end
            # 顧客
            resources :clients do
                collection do
                get "search"
                end
            end
            # カテゴリ
            resources :categories
            # 商品
            resources :products do
                collection do
                get "search"
                post "sort"
                end
            end
            # 商品写真
            resources :product_images
            # 配送コース
            resources :delivery_courses do
                collection do
                get "search"
                end
            end
            # 納品場所
            resources :delivery_locations do
                collection do
                post "replacement"
                end
            end
            # ユーザー
            resources :users do
                collection do
                get "search"
                end
            end
            # 注文
            resources :orders do
                member do
                get "download"
                end
                collection do
                get "search"
                post "print"
                get "order_count"
            end
        end
        resources :order_cancels do
            collection do
                get "search"
            end
        end

            # 管理者
            resources :administrators
            # 休日
            resources :holidays
            # スライド
            resource :slides
            # 規約
            resources :terms
            # 今日の日付
            get "/today", to: "todays#today"
        end
    end

    unless Rails.env.production?
        # メール確認
        mount LetterOpenerWeb::Engine, at: "/letter_opener"
    end

    post "/stripe/order_success", to: "stripe#order_success"
end
