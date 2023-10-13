class OrderHeader < ApplicationRecord
    #--------------------------------------------------
    # リレーション
    #--------------------------------------------------
    belongs_to :user
    has_many :orders
    accepts_nested_attributes_for :orders


    #--------------------------------------------------
    # バリデーション
    #--------------------------------------------------
    validates :total_count,
        presence: true,
        numericality: { greater_than_or_equal_to: 0 }
    validates :total_price,
        presence: true,
        numericality: { greater_than_or_equal_to: 0 }
end
