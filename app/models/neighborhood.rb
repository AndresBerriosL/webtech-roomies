class Neighborhood < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_many :properties, dependent: :restrict_with_error
end