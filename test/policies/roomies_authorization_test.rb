
require "test_helper"

class RoomiesAuthorizationTest < ActiveSupport::TestCase
  setup do
    @host = User.create!(
      name: "Test Host",
      email: "test-host@example.test",
      password: "RoomiesTest2026!",
      role: :member
    )

    @seeker = User.create!(
      name: "Test Seeker",
      email: "test-seeker@example.test",
      password: "RoomiesTest2026!",
      role: :member
    )

    @outsider = User.create!(
      name: "Test Outsider",
      email: "test-outsider@example.test",
      password: "RoomiesTest2026!",
      role: :member
    )

    @moderator = User.create!(
      name: "Test Moderator",
      email: "test-moderator@example.test",
      password: "RoomiesTest2026!",
      role: :moderator
    )

    neighborhood = Neighborhood.create!(
      name: "Test Neighborhood"
    )

    @property = Property.create!(
      host: @host,
      neighborhood: neighborhood,
      address: "Test Street 123",
      property_type: "Apartment",
      bedrooms: 2,
      bathrooms: 1
    )

    @listing = Listing.create!(
      property: @property,
      monthly_rent: 350000,
      deposit: 200000,
      availability_date: Date.current + 10,
      minimum_stay: 3,
      furnished: true,
      private_bathroom: false,
      description: "Test room description",
      status: :published
    )

    @application = Application.create!(
      listing: @listing,
      seeker: @seeker,
      message: "I am interested in this room.",
      move_in_date: Date.current + 20,
      intended_stay: 3
    )

    @visit = Visit.create!(
      application: @application,
      scheduled_at: 2.days.from_now,
      status: :proposed
    )
  end

  test "visitors can browse published listings" do
    assert ListingPolicy.new(nil, @listing).show?
    assert PropertyPolicy.new(nil, @property).show?
  end

  test "outsiders cannot modify properties" do
    assert_not PropertyPolicy.new(@outsider, @property).update?
    assert PropertyPolicy.new(@host, @property).update?
    assert PropertyPolicy.new(@moderator, @property).update?
  end

  test "only moderators manage neighborhoods" do
    neighborhood = Neighborhood.new

    assert_not NeighborhoodPolicy.new(@seeker, neighborhood).create?
    assert NeighborhoodPolicy.new(@moderator, neighborhood).create?
  end

  test "outsiders cannot see applications" do
    assert_not ApplicationPolicy.new(@outsider, @application).show?
    assert ApplicationPolicy.new(@host, @application).show?
    assert ApplicationPolicy.new(@seeker, @application).show?
    assert ApplicationPolicy.new(@moderator, @application).show?
  end

  test "application scopes hide private records" do
    outsider_ids = Pundit.policy_scope!(
      @outsider, Application
    ).pluck(:id)

    host_ids = Pundit.policy_scope!(
      @host, Application
    ).pluck(:id)

    assert_not_includes outsider_ids, @application.id
    assert_includes host_ids, @application.id
  end

  test "moderators cannot accept applications" do
    assert ApplicationPolicy.new(@host, @application).accept?
    assert_not ApplicationPolicy.new(@moderator, @application).accept?
  end

  test "visits are limited to participants" do
    assert VisitPolicy.new(@host, @visit).show?
    assert VisitPolicy.new(@seeker, @visit).show?

    assert_not VisitPolicy.new(@outsider, @visit).show?
    assert_not VisitPolicy.new(@moderator, @visit).cancel?
  end

  test "only moderators can manage reports" do
    report = Report.new(
      listing: @listing,
      reporter: @seeker,
      reason: "Test report"
    )

    assert ReportPolicy.new(@seeker, report).create?
    assert_not ReportPolicy.new(@seeker, report).resolve?
    assert ReportPolicy.new(@moderator, report).resolve?
  end

  test "reviews require a completed visit" do
    review = Review.new(visit: @visit)

    assert_not ReviewPolicy.new(@seeker, review).create?

    @visit.update!(status: :completed)

    assert ReviewPolicy.new(@seeker, review).create?
    assert_not ReviewPolicy.new(@host, review).create?
    assert_not ReviewPolicy.new(@moderator, review).create?
  end
end
