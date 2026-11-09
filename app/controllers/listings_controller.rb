
class ListingsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  before_action :set_listing,
                only: %i[show edit update destroy publish withdraw]
  before_action :set_property, only: %i[new create]

  def index
    authorize Listing, :index?

    @listings = policy_scope(Listing)
                .published
                .includes(property: :neighborhood)
                .order(created_at: :desc)
  end

  def show
    authorize @listing

    @reviews = @listing.property.reviews.includes(
      visit: { application: :seeker }
    )
  end

  def new
    @listing = @property.listings.build
    authorize @listing
  end

  def create
    @listing = @property.listings.build(listing_params)
    @listing.status = :draft
    authorize @listing

    if @listing.save
      redirect_to @listing,
                  notice: "Listing created as draft."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @listing
  end

  def update
    authorize @listing

    if @listing.update(listing_params)
      redirect_to @listing,
                  notice: "Listing updated successfully."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @listing

    if @listing.applications.exists?
      redirect_to @listing,
                  alert: "Cannot delete a listing with applications."
      return
    end

    property = @listing.property

    if @listing.destroy
      redirect_to property_path(property),
                  notice: "Listing deleted successfully."
    else
      redirect_to @listing,
                  alert: "Listing could not be deleted."
    end
  end

  def publish
    authorize @listing

    unless @listing.draft?
      redirect_to @listing,
                  alert: "Only draft listings can be published."
      return
    end

    if @listing.update(status: :published)
      redirect_to @listing,
                  notice: "Listing published successfully."
    else
      redirect_to @listing,
                  alert: @listing.errors.full_messages.to_sentence
    end
  end

  def withdraw
    authorize @listing

    unless @listing.published?
      redirect_to @listing,
                  alert: "Only published listings can be withdrawn."
      return
    end

    if @listing.update(status: :withdrawn)
      redirect_to @listing,
                  notice: "Listing withdrawn successfully."
    else
      redirect_to @listing,
                  alert: @listing.errors.full_messages.to_sentence
    end
  end

  private

  def set_listing
    @listing = Listing.includes(
      property: [:host, :neighborhood, :amenities]
    ).find(params[:id])
  end

  def set_property
    @property = Property.find(params[:property_id])
  end

  def listing_params
    permitted = params.require(:listing).permit(
      :monthly_rent,
      :deposit,
      :availability_date,
      :minimum_stay,
      :furnished,
      :private_bathroom,
      :description,
      :house_rules,
      photos: []
    )

    if permitted[:photos].present? &&
       permitted[:photos].all?(&:blank?)
      permitted.delete(:photos)
    end

    permitted
  end
end
