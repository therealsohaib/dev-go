class Book < ApplicationRecord
  belongs_to :author

  validates :title, presence: true
  validates :isbn, uniqueness: true
  validates :published_date, presence: true
end
