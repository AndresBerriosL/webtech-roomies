class Report < ApplicationRecord
  belongs_to :reporter, class_name: "User", foreign_key: :reporter_id
  belongs_to :listing

  validates :reason, presence: true
end