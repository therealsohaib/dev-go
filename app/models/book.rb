class Book < ApplicationRecord
  belongs_to :author

  validates :title, presence: true
  validates :isbn, uniqueness: true
  validates :publish_date, presence: true
end
