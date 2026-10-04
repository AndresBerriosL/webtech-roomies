class Property < ApplicationRecord
  belongs_to :host, class_name: "User", foreign_key: :host_id
  belongs_to :neighborhood

  has_many :property_amenities, dependent: :destroy
  has_many :amenities, through: :property_amenities
  has_many :listings, dependent: :destroy
  has_many :applications, through: :listings
  has_many :visits, through: :applications
  has_many :reviews, through: :visits

  validates :address, presence: true
  validates :property_type, presence: true
  validates :bedrooms, numericality: { only_integer: true, greater_than: 0 }
  validates :bathrooms, numericality: { only_integer: true, greater_than: 0 }
end