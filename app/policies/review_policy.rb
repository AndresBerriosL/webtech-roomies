
class ReviewPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def new?
    create?
  end

  def create?
    return false unless user&.member?
    return false unless record.visit

    record.visit.completed? &&
      record.visit.application.seeker_id == user.id &&
      !Review.exists?(visit_id: record.visit.id)
  end

  def destroy?
    return false unless user

    user.moderator? ||
      record.visit.application.seeker_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
