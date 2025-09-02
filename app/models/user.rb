class User < ApplicationRecord
  has_many :borrows, dependent: :destroy
  has_many :books , through: :borrows


  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }
end
