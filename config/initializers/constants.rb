module Constants
    #--------------------------------------------------
    # フロント側
    #--------------------------------------------------
    if Rails.env.production?
        FRONT_URL = "https://sennari-app.com"
    elsif Rails.env.staging?
        FRONT_URL = "https://sennnari-front-970c8fdd8060.herokuapp.com"
    else
        FRONT_URL = "http://localhost:3001"
    end

    #--------------------------------------------------
    # メールアドレス
    #--------------------------------------------------
    ADMIN_EMAIL_ADDRESS = ""            # 管理画面ログインアカウント用
    SEND_SHOP_EMAIL = "info@sennari-app.com"                   # 送信メール
    RECEIVING_SHOP_EMAIL = ""           # 受信メール
    BACKUP_SHOP_EMAIL = ""                 # バックアップ用
    UNCODE_EMAIL = ""
end