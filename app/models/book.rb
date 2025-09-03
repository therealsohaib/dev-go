class Book < ApplicationRecord
  belongs_to :author

  scope :published_after, ->(year) {where( published_date: year)}
  scope :recently_added, -> { order(created_at: :desc).limit(5) }

  validates :title, presence: true
  validates :isbn, uniqueness: true
  validates :published_date, presence: true
end
