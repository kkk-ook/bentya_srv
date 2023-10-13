class Term < ApplicationRecord
    #--------------------------------------------------
    # バリデーション
    #--------------------------------------------------
    validates :title, presence: true
end
