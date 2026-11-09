
class PropertyPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.listings.published.exists? ||
      user&.moderator? ||
      (user && record.host_id == user.id)
  end

  def create?
    user.present?
  end

  def new?
    create?
  end

  def update?
    user.present? &&
      (user.moderator? || record.host_id == user.id)
  end

  def edit?
    update?
  end

  def destroy?
    update?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      public_properties = scope.where(
        id: Listing.published.select(:property_id)
      )

      return public_properties unless user
      return scope.all if user.moderator?

      public_properties.or(
        scope.where(host_id: user.id)
      )
    end
  end
end
