
class ReportPolicy < ApplicationPolicy
  def index?
    user&.moderator? || false
  end

  def show?
    return false unless user

    user.moderator? ||
      record.reporter_id == user.id
  end

  def new?
    create?
  end

  def create?
    user.present? &&
      record.listing.present?
  end

  def resolve?
    user&.moderator? &&
      record.pending? || false
  end

  def destroy?
    false
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user
      return scope.all if user.moderator?

      scope.where(reporter_id: user.id)
    end
  end
end
