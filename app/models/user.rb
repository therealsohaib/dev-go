class User < ApplicationRecord
  has_many :borrows, dependent: :destroy
  has_many :books , through: :borrows

  scope :gmail_users, -> { where("email LIKE ?", "%@elgrocer.com") }


  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }
end
