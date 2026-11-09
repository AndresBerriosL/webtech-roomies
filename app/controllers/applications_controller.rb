
class ApplicationsController < ApplicationController
  before_action :set_application,
                only: %i[show withdraw shortlist reject accept]

  def index
    authorize Application, :index?

    @applications = policy_scope(Application)
      .includes(:seeker, listing: { property: :neighborhood })
      .order(created_at: :desc)
  end

  def show
    authorize @application
  end

  def new
    @listing = Listing.find(params[:listing_id])
    @application = @listing.applications.build(seeker: current_user)
    authorize @application

    if @listing.applications.exists?(seeker: current_user)
      redirect_to @listing,
                  alert: "You have already applied to this listing."
      return
    end

    @application.move_in_date = @listing.availability_date
    @application.intended_stay = @listing.minimum_stay
  end

  def create
    @listing = Listing.find(params.require(:application)[:listing_id])
    @application = @listing.applications.build(application_params)
    @application.seeker = current_user
    @application.status = :pending

    authorize @application

    if @application.save
      redirect_to @application, notice: "Application submitted successfully."
    else
      flash.now[:alert] = @application.errors.full_messages.to_sentence
      render :new, status: :unprocessable_content
    end
  end

  def withdraw
    authorize @application

    unless @application.pending? || @application.shortlisted?
      redirect_to @application, alert: "This application cannot be withdrawn."
      return
    end

    if @application.update(status: :withdrawn)
      redirect_to @application, notice: "Application withdrawn successfully."
    else
      redirect_to @application,
                  alert: @application.errors.full_messages.to_sentence
    end
  end

  def shortlist
    authorize @application

    unless @application.pending? && @application.listing.published?
      redirect_to @application, alert: "This application cannot be shortlisted."
      return
    end

    @application.update!(status: :shortlisted)
    redirect_to @application, notice: "Application shortlisted successfully."
  end

  def reject
    authorize @application

    unless (@application.pending? || @application.shortlisted?) &&
           @application.listing.published?
      redirect_to @application, alert: "This application cannot be rejected."
      return
    end

    @application.update!(status: :rejected)
    redirect_to @application, notice: "Application rejected successfully."
  end

  def accept
    authorize @application

    begin
      Application.transaction do
        listing = Listing.lock.find(@application.listing_id)
        @application.reload

        unless listing.published? &&
               (@application.pending? || @application.shortlisted?)
          raise ActiveRecord::Rollback
        end

        @application.update!(status: :accepted)

        listing.applications
          .where(status: [:pending, :shortlisted])
          .where.not(id: @application.id)
          .find_each do |other_application|
            other_application.update!(status: :rejected)
          end

        listing.update!(status: :reserved)
      end

      @application.reload

      if @application.accepted?
        redirect_to @application, notice: "Application accepted. Listing reserved."
      else
        redirect_to @application, alert: "This application can no longer be accepted."
      end
    rescue ActiveRecord::RecordInvalid => e
      redirect_to @application,
                  alert: e.record.errors.full_messages.to_sentence
    end
  end

  private

  def set_application
    @application = policy_scope(Application)
      .includes(:seeker, :visits, listing: { property: :neighborhood })
      .find_by(id: params[:id])

    return if @application

    redirect_to applications_path,
                alert: "Application not found or inaccessible."
  end

  def application_params
    params.require(:application).permit(
      :message,
      :move_in_date,
      :intended_stay
    )
  end
end
