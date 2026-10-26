
class ListingsController < ApplicationController
  before_action :set_listing, only: %i[show edit update destroy publish withdraw]
  before_action :set_property, only: %i[new create]
  before_action :require_owner, only: %i[edit update destroy publish withdraw]

  def index
    @listings = Listing.published
                       .includes(property: :neighborhood)
                       .order(created_at: :desc)
  end

  def show
    unless @listing.published? || @listing.property.host == current_user
      redirect_to listings_path,
                  alert: "This listing is not available."
      return
    end

    @reviews = @listing.property.reviews.includes(
      visit: { application: :seeker }
    )
  end

  def new
    return unless check_property_owner

    @listing = @property.listings.build
  end

  def create
    return unless check_property_owner

    @listing = @property.listings.build(listing_params)
    @listing.status = :draft

    if @listing.save
      redirect_to @listing,
                  notice: "Listing created as draft."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @listing.update(listing_params)
      redirect_to @listing,
                  notice: "Listing updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @listing.applications.exists?
      redirect_to @listing,
                  alert: "Cannot delete a listing with applications."
      return
    end

    if @listing.destroy
      redirect_to property_path(@listing.property),
                  notice: "Listing deleted successfully."
    else
      redirect_to @listing,
                  alert: "Listing could not be deleted."
    end
  end

  
  def publish
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

  def check_property_owner
    return true if @property.host == current_user

    redirect_to properties_path,
                alert: "You can only create listings for your own properties."
    false
  end

  def require_owner
    return if @listing.property.host == current_user

    redirect_to listings_path,
                alert: "You can only modify your own listings."
  end

  
  def listing_params
    params.require(:listing).permit(
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
  end

end
