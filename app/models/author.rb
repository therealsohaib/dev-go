class Author < ApplicationRecord
  has_many :books

  scope :with_books, -> { joins(:books).distinct }
  scope :prolific, ->(count = 5) { joins(:books).group("authors.id").having("COUNT(books.id) >= ?", count) }

  validates :name, presence: true, uniqueness: true
end
