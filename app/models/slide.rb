class Slide < ApplicationRecord
    #--------------------------------------------------
    # スコープ
    #--------------------------------------------------
    scope :sorted, -> { order(position: :asc) }
end
