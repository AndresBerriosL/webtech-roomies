
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    record == Application && user.present?
  end

  def show?
    return false unless record.is_a?(Application) && user

    user.moderator? ||
      record.seeker_id == user.id ||
      record.listing.property.host_id == user.id
  end

  def create?
    return false unless record.is_a?(Application) && user

    record.listing.published? &&
      record.listing.property.host_id != user.id
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def withdraw?
    record.is_a?(Application) &&
      user.present? &&
      user.member? &&
      record.seeker_id == user.id
  end

  def shortlist?
    host_can_manage?
  end

  def reject?
    host_can_manage?
  end

  def accept?
    host_can_manage?
  end

  private

  def host_can_manage?
    record.is_a?(Application) &&
      user.present? &&
      user.member? &&
      record.listing.property.host_id == user.id
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      return scope.none unless user
      return scope.none unless scope == Application
      return scope.all if user.moderator?

      scope.joins(listing: :property)
           .where(
             "applications.seeker_id = :id OR properties.host_id = :id",
             id: user.id
           )
           .distinct
    end
  end
end
