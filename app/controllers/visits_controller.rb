
class VisitsController < ApplicationController
  before_action :set_application, only: %i[new create]
  before_action :set_visit, only: %i[show edit update confirm cancel complete]
  def new
    return unless host_can_propose?

    @visit = @application.visits.build
  end

  def create
    return unless host_can_propose?

    @visit = @application.visits.build(visit_params)
    @visit.status = :proposed

    if @visit.scheduled_at.present? &&
       @visit.scheduled_at <= Time.current
      @visit.errors.add(:scheduled_at, "must be in the future")
    end

    if @visit.errors.empty? && @visit.save
      redirect_to @application,
                  notice: "Visit proposed successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    return unless participant?

  end

  
def edit
  return unless participant?
  return unless host?

  unless @visit.proposed? || @visit.confirmed?
    redirect_to @visit,
                alert: "This visit cannot be rescheduled."
  end
end

def update
  return unless participant?
  return unless host?

  unless @visit.proposed? || @visit.confirmed?
    redirect_to @visit,
                alert: "This visit cannot be rescheduled."
    return
  end

  new_date = visit_params[:scheduled_at]

  if new_date.blank? || Time.zone.parse(new_date) <= Time.current
    @visit.errors.add(:scheduled_at, "must be in the future")
    render :edit, status: :unprocessable_entity
    return
  end

  if @visit.update(
    scheduled_at: new_date,
    status: :proposed
  )
    redirect_to @visit,
                notice: "Visit rescheduled successfully. Awaiting confirmation."
  else
    render :edit, status: :unprocessable_entity
  end
end


  def confirm
    return unless participant?
    return unless seeker?

    if @visit.proposed? && @visit.update(status: :confirmed)
      redirect_to @visit, notice: "Visit confirmed successfully."
    else
      redirect_to @visit, alert: "This visit cannot be confirmed."
    end
  end

  def cancel
    return unless participant?

    if (@visit.proposed? || @visit.confirmed?) &&
       @visit.update(status: :cancelled)
      redirect_to @visit, notice: "Visit cancelled successfully."
    else
      redirect_to @visit, alert: "This visit cannot be cancelled."
    end
  end

  def complete
    return unless participant?
    return unless host?

    if @visit.confirmed? &&
       @visit.scheduled_at <= Time.current &&
       @visit.update(status: :completed)
      redirect_to @visit, notice: "Visit completed successfully."
    else
      redirect_to @visit, alert: "This visit cannot be completed."
    end
  end

  private

  def set_application
    @application = Application.find(params[:application_id])
  end

  def set_visit
    @visit = Visit.includes(application: { listing: :property })
                  .find(params[:id])
    @application = @visit.application
  end

  def host?
    @application.listing.property.host_id == current_user.id
  end

  def seeker?
    @application.seeker_id == current_user.id
  end

  def participant?
    return true if host? || seeker?

    redirect_to applications_path,
                alert: "You are not authorized to view this visit."
    false
  end

  def host_can_propose?
    unless host? &&
            @application.shortlisted? &&
            @application.listing.published?

        redirect_to applications_path,
                    alert: "Only the host can propose a visit for a shortlisted application."
        return false
    end

    if @application.visits.where(status: [:proposed, :confirmed]).exists?
        redirect_to @application,
                    alert: "There is already an active visit for this application."
        return false
    end

    true
    end             

  def visit_params
    params.require(:visit).permit(:scheduled_at)
  end
end
