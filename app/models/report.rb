
class Report < ApplicationRecord
  belongs_to :reporter,
             class_name: "User",
             foreign_key: :reporter_id

  belongs_to :listing

  enum :status, {
    pending: 0,
    resolved: 1
  }, default: :pending

  validates :reason, presence: true

  scope :recent_first, -> { order(created_at: :desc) }
end
