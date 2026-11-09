
class VisitPolicy < ApplicationPolicy
  def show?
    participant?
  end

  def new?
    create?
  end

  def create?
    participant? &&
      record.application.shortlisted? &&
      record.application.listing.published?
  end

  def edit?
    update?
  end

  def update?
    host?
  end

  def confirm?
    seeker?
  end

  def cancel?
    participant?
  end

  def complete?
    host?
  end

  private

  def participant?
    host? || seeker?
  end

  def host?
    user.present? &&
      user.member? &&
      record.application.listing.property.host_id == user.id
  end

  def seeker?
    user.present? &&
      user.member? &&
      record.application.seeker_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user&.member?

      scope.joins(application: { listing: :property })
           .where(
             "applications.seeker_id = :id OR properties.host_id = :id",
             id: user.id
           )
           .distinct
    end
  end
end
