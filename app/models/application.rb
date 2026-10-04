class Application < ApplicationRecord
  belongs_to :listing
  belongs_to :seeker, class_name: "User", foreign_key: :seeker_id

  enum :status, {
    pending: 0,
    shortlisted: 1,
    accepted: 2,
    rejected: 3,
    withdrawn: 4
  }, default: :pending

  validates :message, presence: true
  validates :move_in_date, presence: true

  validates :intended_stay,
            numericality: { only_integer: true, greater_than: 0 }

  validates :seeker_id,
            uniqueness: { scope: :listing_id }

  validate :cannot_apply_to_own_listing
  validate :listing_must_be_published, on: :create

  has_many :visits, dependent: :destroy

  scope :pending_answer, -> { where(status: :pending) }

  private

  def cannot_apply_to_own_listing
    return if listing.blank? || seeker.blank?

    if listing.property.host_id == seeker_id
      errors.add(:seeker, "cannot apply to their own listing")
    end
  end

  def listing_must_be_published
    return if listing.blank?

    unless listing.published?
      errors.add(:listing, "must be published")
    end
  end
end