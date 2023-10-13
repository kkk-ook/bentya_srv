class OrderDetail < ApplicationRecord
    #--------------------------------------------------
    # リレーション
    #--------------------------------------------------
    belongs_to :order

    #--------------------------------------------------
    # バリデーション
    #--------------------------------------------------
    validates :count,
        presence: true,
        numericality: { greater_than_or_equal_to: 0 }
    validates :provision_on,
        presence: true

end
