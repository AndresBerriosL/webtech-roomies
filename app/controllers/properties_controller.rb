
class PropertiesController < ApplicationController
  before_action :set_property, only: %i[show edit update destroy]
  before_action :require_owner, only: %i[edit update destroy]

  def index
    @properties = Property
                  .includes(:host, :neighborhood, :amenities, :listings)
                  .order(created_at: :desc)
  end

  def show
    @reviews = @property.reviews.includes(
      visit: { application: :seeker }
    )
  end

  def new
    @property = Property.new
  end

  def create
    @property = Property.new(property_params)
    @property.host = current_user

    if @property.save
      redirect_to @property,
                  notice: "Property created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @property.update(property_params)
      redirect_to @property,
                  notice: "Property updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @property.listings.exists?
      redirect_to @property,
                  alert: "Cannot delete a property with listings."
      return
    end

    if @property.destroy
      redirect_to properties_path,
                  notice: "Property deleted successfully."
    else
      redirect_to @property,
                  alert: "Property could not be deleted."
    end
  end

  private

  def set_property
    @property = Property
                .includes(:host, :neighborhood, :amenities, :listings)
                .find(params[:id])
  end

  def require_owner
    return if @property.host == current_user

    redirect_to properties_path,
                alert: "You can only modify your own properties."
  end

  def property_params
    params.require(:property).permit(
      :address,
      :neighborhood_id,
      :property_type,
      :bedrooms,
      :bathrooms,
      :shared_spaces,
      amenity_ids: []
    )
  end
end
