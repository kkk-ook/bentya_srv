class DeviseMailer < Devise::Mailer
    include Devise::Controllers::UrlHelpers
    default template_path: 'devise/mailer'
    default from: Constants::SEND_SHOP_EMAIL

    def confirmation_instructions(record, token, opts={})
        # record内の"unconfirmed_email"の有無で登録／変更を仕分け
        # opts属性を上書きすることで、Subjectやfromなどのヘッダー情報を変更することが可能！
        if record.unconfirmed_email.blank?
            opts[:subject] = "【千成】新規会員のお手続きご案内"
        else
            opts[:subject] = "【千成】メールアドレス変更手続きを完了させてください"
        end
        #件名の指定以外は親を継承
        super
    end
end
