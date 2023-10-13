class CartDetail < ApplicationRecord
    attribute :count, default: 0

    #--------------------------------------------------
    # リレーション
    #--------------------------------------------------
    #カート 1対多
    belongs_to :cart

    #--------------------------------------------------
    # バリデーション
    #--------------------------------------------------
    validates :count,
        numericality: { greater_than_or_equal_to: 0 }
    validates :delivery_day,
        presence: true

end
