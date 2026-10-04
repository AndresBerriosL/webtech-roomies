class Visit < ApplicationRecord
  belongs_to :application

  enum :status, {
    proposed: 0,
    confirmed: 1,
    cancelled: 2,
    completed: 3
  }, default: :proposed

  validates :scheduled_at, presence: true

  validate :scheduled_after_application_created

  has_one :review, dependent: :destroy

  private

  def scheduled_after_application_created
    return if scheduled_at.blank? || application.blank? || application.created_at.blank?

    if scheduled_at <= application.created_at
      errors.add(:scheduled_at, "must be after the application was created")
    end
  end
end