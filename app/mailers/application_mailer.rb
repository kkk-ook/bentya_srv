class ApplicationMailer < ActionMailer::Base
  default from: Constants::SEND_SHOP_EMAIL
  layout "mailer"
end
