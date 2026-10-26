class Listing < ApplicationRecord
  belongs_to :property
  has_many_attached :photos

  enum :status, {
    draft: 0,
    published: 1,
    reserved: 2,
    rented: 3,
    withdrawn: 4
  }, default: :draft

  validates :monthly_rent,
            numericality: { greater_than: 0 }

  validates :deposit,
            numericality: { greater_than_or_equal_to: 0 }

  validates :minimum_stay,
            numericality: { only_integer: true, greater_than: 0 }

  validates :availability_date, presence: true
  validates :description, presence: true

  validate :availability_date_cannot_be_in_the_past

  has_many :applications, dependent: :destroy
  has_many :saved_listings, dependent: :destroy
  has_many :saving_users,
          through: :saved_listings,
          source: :user
  has_many :reports, dependent: :destroy
  has_many :visits, through: :applications
  has_many :reviews, through: :visits

  scope :available_from, ->(date) {
    where("availability_date <= ?", date)
  }

  scope :under_rent, ->(amount) {
    where("monthly_rent <= ?", amount)
  }

  private

  def availability_date_cannot_be_in_the_past
    return if availability_date.blank?

    if availability_date < Date.current
      errors.add(:availability_date, "cannot be in the past")
    end
  end
end