class Review < ApplicationRecord
  belongs_to :visit

  validates :visit_id, uniqueness: true

  validates :rating,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 5
            }

  validates :comment, presence: true

  validate :visit_must_be_completed

  private

  def visit_must_be_completed
    return if visit.blank?

    unless visit.completed?
      errors.add(:visit, "must be completed before it can be reviewed")
    end
  end
end