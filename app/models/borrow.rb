class Borrow < ApplicationRecord
  belongs_to :user
  belongs_to :book
  scope :due, -> {where("due_date<?", Date.today)}
  scope :by_user, ->(user_id) { where(user_id: user_id) }


  validates :book_id, uniqueness: { scope: :user_id }
  validate :due_date_after_issue

  private
  def due_date_after_issue
    if due_date.present? && issue_date.present? && due_date <= issue_date
      errors.add(:due_date, "must be after issue")
    end
  end
end
