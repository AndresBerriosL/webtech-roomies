# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "Cleaning database..."

Review.delete_all
Visit.delete_all
Report.delete_all
SavedListing.delete_all
Application.delete_all
Listing.delete_all
PropertyAmenity.delete_all
Property.delete_all
Amenity.delete_all
Neighborhood.delete_all
User.delete_all

puts "Creating users..."

andres = User.create!(
  name: "Andrés Berríos",
  email: "andres@example.com",
  role: :member
)

sofia = User.create!(
  name: "Sofía Martínez",
  email: "sofia@example.com",
  role: :member
)

matias = User.create!(
  name: "Matías González",
  email: "matias@example.com",
  role: :member
)

camila = User.create!(
  name: "Camila Rojas",
  email: "camila@example.com",
  role: :member
)

moderator = User.create!(
  name: "Roomies Moderator",
  email: "moderator@roomies.cl",
  role: :moderator
)

puts "Creating neighborhoods..."

providencia = Neighborhood.create!(name: "Providencia")
nunoa = Neighborhood.create!(name: "Ñuñoa")
las_condes = Neighborhood.create!(name: "Las Condes")
santiago = Neighborhood.create!(name: "Santiago Centro")

puts "Creating amenities..."

wifi = Amenity.create!(name: "Wi-Fi")
laundry = Amenity.create!(name: "Laundry")
parking = Amenity.create!(name: "Parking")
balcony = Amenity.create!(name: "Balcony")
gym = Amenity.create!(name: "Gym")
heating = Amenity.create!(name: "Heating")

puts "Creating properties..."

property_1 = Property.create!(
  host: sofia,
  neighborhood: providencia,
  address: "Av. Pedro de Valdivia 1250",
  property_type: "Apartment",
  bedrooms: 3,
  bathrooms: 2,
  shared_spaces: "Living room, kitchen and balcony"
)

property_2 = Property.create!(
  host: matias,
  neighborhood: nunoa,
  address: "Av. Irarrázaval 3250",
  property_type: "Apartment",
  bedrooms: 4,
  bathrooms: 2,
  shared_spaces: "Living room, kitchen and terrace"
)

property_3 = Property.create!(
  host: camila,
  neighborhood: las_condes,
  address: "Av. Apoquindo 4500",
  property_type: "Apartment",
  bedrooms: 2,
  bathrooms: 2,
  shared_spaces: "Living room and kitchen"
)

property_4 = Property.create!(
  host: andres,
  neighborhood: santiago,
  address: "Portugal 820",
  property_type: "House",
  bedrooms: 5,
  bathrooms: 3,
  shared_spaces: "Kitchen, living room and patio"
)

puts "Adding amenities..."

[property_1, property_2, property_3, property_4].each do |property|
  PropertyAmenity.create!(property: property, amenity: wifi)
end

PropertyAmenity.create!(property: property_1, amenity: balcony)
PropertyAmenity.create!(property: property_1, amenity: laundry)

PropertyAmenity.create!(property: property_2, amenity: laundry)
PropertyAmenity.create!(property: property_2, amenity: heating)

PropertyAmenity.create!(property: property_3, amenity: gym)
PropertyAmenity.create!(property: property_3, amenity: parking)

PropertyAmenity.create!(property: property_4, amenity: laundry)
PropertyAmenity.create!(property: property_4, amenity: parking)

puts "Creating listings..."

listing_1 = Listing.create!(
  property: property_1,
  monthly_rent: 420_000,
  deposit: 420_000,
  availability_date: Date.current + 10.days,
  minimum_stay: 6,
  furnished: true,
  private_bathroom: false,
  description: "Bright furnished room close to Metro Pedro de Valdivia.",
  status: :published
)

listing_2 = Listing.create!(
  property: property_2,
  monthly_rent: 380_000,
  deposit: 380_000,
  availability_date: Date.current + 20.days,
  minimum_stay: 4,
  furnished: true,
  private_bathroom: false,
  description: "Comfortable room in Ñuñoa near shops and public transport.",
  status: :published
)

listing_3 = Listing.create!(
  property: property_3,
  monthly_rent: 550_000,
  deposit: 550_000,
  availability_date: Date.current + 15.days,
  minimum_stay: 6,
  furnished: true,
  private_bathroom: true,
  description: "Private room with bathroom in a modern Las Condes apartment.",
  status: :published
)

listing_4 = Listing.create!(
  property: property_4,
  monthly_rent: 300_000,
  deposit: 300_000,
  availability_date: Date.current + 30.days,
  minimum_stay: 3,
  furnished: false,
  private_bathroom: false,
  description: "Large room in a shared house near Santiago Centro.",
  status: :published
)

listing_5 = Listing.create!(
  property: property_2,
  monthly_rent: 350_000,
  deposit: 350_000,
  availability_date: Date.current + 40.days,
  minimum_stay: 6,
  furnished: true,
  private_bathroom: false,
  description: "Second available room in the same Ñuñoa apartment.",
  status: :draft
)

listing_6 = Listing.create!(
  property: property_1,
  monthly_rent: 400_000,
  deposit: 400_000,
  availability_date: Date.current,
  minimum_stay: 6,
  furnished: true,
  private_bathroom: false,
  description: "Room that has already been rented.",
  status: :rented
)

listing_7 = Listing.create!(
  property: property_4,
  monthly_rent: 320_000,
  deposit: 320_000,
  availability_date: Date.current + 25.days,
  minimum_stay: 3,
  furnished: true,
  private_bathroom: false,
  description: "Listing withdrawn by the host.",
  status: :withdrawn
)

puts "Creating applications..."

application_pending = Application.create!(
  listing: listing_1,
  seeker: andres,
  message: "I study nearby and I am looking for a quiet place to live.",
  move_in_date: Date.current + 15.days,
  intended_stay: 12,
  status: :pending
)

application_shortlisted = Application.create!(
  listing: listing_2,
  seeker: camila,
  message: "I really like the neighborhood and would love to visit.",
  move_in_date: Date.current + 25.days,
  intended_stay: 8,
  status: :shortlisted
)

application_accepted = Application.create!(
  listing: listing_3,
  seeker: andres,
  message: "The location is perfect for me and I am interested in staying long-term.",
  move_in_date: Date.current + 20.days,
  intended_stay: 12,
  status: :accepted,
  created_at: 10.days.ago,
  updated_at: 10.days.ago
)

application_rejected = Application.create!(
  listing: listing_3,
  seeker: matias,
  message: "I am interested in the room and available to move soon.",
  move_in_date: Date.current + 22.days,
  intended_stay: 6,
  status: :rejected
)

application_withdrawn = Application.create!(
  listing: listing_4,
  seeker: sofia,
  message: "I would like to know more about the house.",
  move_in_date: Date.current + 35.days,
  intended_stay: 5,
  status: :withdrawn
)

# Listing 3 has an accepted application, so it becomes reserved.
listing_3.update!(status: :reserved)

puts "Creating visits..."

visit_proposed = Visit.create!(
  application: application_pending,
  scheduled_at: Time.current + 3.days,
  status: :proposed
)

visit_confirmed = Visit.create!(
  application: application_shortlisted,
  scheduled_at: Time.current + 4.days,
  status: :confirmed
)

visit_completed = Visit.create!(
  application: application_accepted,
  scheduled_at: 3.days.ago,
  status: :completed
)

visit_cancelled = Visit.create!(
  application: application_rejected,
  scheduled_at: Time.current + 2.days,
  status: :cancelled
)

puts "Creating review..."

Review.create!(
  visit: visit_completed,
  rating: 5,
  comment: "Great apartment, excellent location and a very welcoming host."
)

puts "Creating saved listings..."

SavedListing.create!(user: andres, listing: listing_2)
SavedListing.create!(user: camila, listing: listing_1)
SavedListing.create!(user: sofia, listing: listing_3)

puts "Creating reports..."

Report.create!(
  reporter: camila,
  listing: listing_4,
  reason: "Some information in the listing may be outdated."
)

Report.create!(
  reporter: moderator,
  listing: listing_2,
  reason: "Listing flagged for manual verification."
)

puts "Seeds completed!"
puts "#{User.count} users"
puts "#{Neighborhood.count} neighborhoods"
puts "#{Amenity.count} amenities"
puts "#{Property.count} properties"
puts "#{Listing.count} listings"
puts "#{Application.count} applications"
puts "#{Visit.count} visits"
puts "#{Review.count} reviews"