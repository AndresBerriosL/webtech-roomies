class ApplicationsController < ApplicationController
  def index
    @applications = Application
      .joins(listing: :property)
      .where(
        "applications.seeker_id = :user_id OR properties.host_id = :user_id",
        user_id: current_user.id
      )
      .includes(:seeker, listing: { property: :neighborhood })
      .order(created_at: :desc)
  end

  def show
    @application = Application
                   .includes(
                     :seeker,
                     :visits,
                     listing: { property: :neighborhood }
                   )
                   .find(params[:id])
    unless @application.seeker == current_user ||
          @application.listing.property.host == current_user
      redirect_to applications_path,
                  alert: "You are not authorized to view this application."
      return
    end
  end
  
  def new
    @listing = Listing.find(params[:listing_id])

    unless @listing.published?
      redirect_to listings_path,
                  alert: "This listing is not accepting applications."
      return
    end

    if @listing.property.host == current_user
      redirect_to @listing,
                  alert: "You cannot apply to your own listing."
      return
    end

    if @listing.applications.exists?(seeker: current_user)
      redirect_to @listing,
                  alert: "You have already applied to this listing."
      return
    end

    @application = @listing.applications.build
    @application.move_in_date = @listing.availability_date
    @application.intended_stay = @listing.minimum_stay
  end

  def create
    @listing = Listing.find(params[:application][:listing_id])
    @application = @listing.applications.build(application_params)

    # Always use the selected user, not a submitted seeker_id.
    @application.seeker = current_user
    @application.status = :pending

    if @application.save
      redirect_to @application,
                  notice: "Application submitted successfully."
    else
      flash.now[:alert] = @application.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def withdraw
  @application = Application.find(params[:id])

  unless @application.seeker == current_user
    redirect_to applications_path,
                alert: "You can only withdraw your own applications."
    return
  end

  unless @application.pending? || @application.shortlisted?
    redirect_to @application,
                alert: "This application cannot be withdrawn."
    return
  end

  if @application.update(status: :withdrawn)
    redirect_to @application,
                notice: "Application withdrawn successfully."
  else
    redirect_to @application,
                alert: @application.errors.full_messages.to_sentence
  end
end


def shortlist
  application = Application.find(params[:id])

  unless application.listing.property.host == current_user
    redirect_to applications_path,
                alert: "Only the host can manage applications."
    return
  end

  unless application.pending? && application.listing.published?
    redirect_to application,
                alert: "This application cannot be shortlisted."
    return
  end

  application.update!(status: :shortlisted)

  redirect_to application,
              notice: "Application shortlisted successfully."
end

def reject
  application = Application.find(params[:id])

  unless application.listing.property.host == current_user
    redirect_to applications_path,
                alert: "Only the host can manage applications."
    return
  end

  unless (application.pending? || application.shortlisted?) &&
         application.listing.published?
    redirect_to application,
                alert: "This application cannot be rejected."
    return
  end

  application.update!(status: :rejected)

  redirect_to application,
              notice: "Application rejected successfully."
end

def accept
  application = Application.find(params[:id])

  unless application.listing.property.host == current_user
    redirect_to applications_path,
                alert: "Only the host can manage applications."
    return
  end

  begin
    Application.transaction do
      listing = Listing.lock.find(application.listing_id)
      application.reload

      unless listing.published? &&
             (application.pending? || application.shortlisted?)
        raise ActiveRecord::Rollback
      end

      application.update!(status: :accepted)

      listing.applications
             .where(status: [:pending, :shortlisted])
             .where.not(id: application.id)
             .update_all(status: Application.statuses[:rejected],
                         updated_at: Time.current)

      listing.update!(status: :reserved)
    end

    application.reload

    if application.accepted?
      redirect_to application,
                  notice: "Application accepted. Listing reserved."
    else
      redirect_to application,
                  alert: "This application can no longer be accepted."
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_to application,
                alert: e.record.errors.full_messages.to_sentence
  end
end


  private

  def application_params
    params.require(:application).permit(
      :message,
      :move_in_date,
      :intended_stay
    )
  end

end