class User < ApplicationRecord
  has_many :books , through: :borrows, dependent: authors


  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }
end
