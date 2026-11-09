
class VisitsController < ApplicationController
  before_action :set_application, only: %i[new create]
  before_action :set_visit,
                only: %i[show edit update confirm cancel complete]

  def new
    @visit = @application.visits.build
    authorize @visit

    return unless ensure_no_active_visit
  end

  def create
    @visit = @application.visits.build(visit_params)
    @visit.status = :proposed
    authorize @visit

    return unless ensure_no_active_visit

    if @visit.scheduled_at.blank? ||
       @visit.scheduled_at <= Time.current
      @visit.errors.add(:scheduled_at, "must be in the future")
    end

    if @visit.errors.empty? && @visit.save
      redirect_to @application,
                  notice: "Visit proposed successfully."
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
    authorize @visit
  end

  def edit
    authorize @visit

    unless @visit.proposed? || @visit.confirmed?
      redirect_to @visit,
                  alert: "This visit cannot be rescheduled."
    end
  end

  def update
    authorize @visit

    unless @visit.proposed? || @visit.confirmed?
      redirect_to @visit,
                  alert: "This visit cannot be rescheduled."
      return
    end

    new_date = visit_params[:scheduled_at]

    if new_date.blank? ||
       Time.zone.parse(new_date) <= Time.current
      @visit.errors.add(:scheduled_at, "must be in the future")
      render :edit, status: :unprocessable_content
      return
    end

    if @visit.update(
      scheduled_at: new_date,
      status: :proposed
    )
      redirect_to @visit,
                  notice: "Visit rescheduled successfully."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def confirm
    authorize @visit

    if @visit.proposed? && @visit.update(status: :confirmed)
      redirect_to @visit,
                  notice: "Visit confirmed successfully."
    else
      redirect_to @visit,
                  alert: "This visit cannot be confirmed."
    end
  end

  def cancel
    authorize @visit

    if (@visit.proposed? || @visit.confirmed?) &&
       @visit.update(status: :cancelled)
      redirect_to @visit,
                  notice: "Visit cancelled successfully."
    else
      redirect_to @visit,
                  alert: "This visit cannot be cancelled."
    end
  end

  def complete
    authorize @visit

    if @visit.confirmed? &&
       @visit.scheduled_at <= Time.current &&
       @visit.update(status: :completed)
      redirect_to @visit,
                  notice: "Visit completed successfully."
    else
      redirect_to @visit,
                  alert: "This visit cannot be completed."
    end
  end

  private

  def set_application
    @application = policy_scope(Application)
                   .find(params[:application_id])
  end

  def set_visit
    @visit = policy_scope(Visit)
             .includes(application: { listing: :property })
             .find(params[:id])

    @application = @visit.application
  end

  def ensure_no_active_visit
    if @application.visits
                   .where(status: %i[proposed confirmed])
                   .exists?
      redirect_to @application,
                  alert: "There is already an active visit."
      return false
    end

    true
  end

  def visit_params
    params.require(:visit).permit(:scheduled_at)
  end
end
