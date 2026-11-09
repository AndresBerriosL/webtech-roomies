
class ListingPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.published? ||
      user&.moderator? ||
      (user && record.property.host_id == user.id)
  end

  def create?
    user.present? &&
      (user.moderator? ||
       record.property.host_id == user.id)
  end

  def new?
    create?
  end

  def update?
    user.present? &&
      (user.moderator? ||
       record.property.host_id == user.id)
  end

  def edit?
    update?
  end

  def destroy?
    update?
  end

  def publish?
    update?
  end

  def withdraw?
    update?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      public_listings = scope.published

      return public_listings unless user
      return scope.all if user.moderator?

      public_listings.or(
        scope.where(
          property_id: Property.where(
            host_id: user.id
          ).select(:id)
        )
      )
    end
  end
end
