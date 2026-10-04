class User < ApplicationRecord
  enum :role, { member: 0, moderator: 1 }, default: :member
  has_many :properties, foreign_key: :host_id, dependent: :destroy
  has_many :applications, foreign_key: :seeker_id, dependent: :destroy
  has_many :saved_listings, dependent: :destroy
  has_many :saved_listings_records,
         through: :saved_listings,
         source: :listing
  has_many :reports,
            foreign_key: :reporter_id,
            dependent: :destroy


  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end