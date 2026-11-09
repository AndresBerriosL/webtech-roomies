
class PropertiesController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  before_action :set_property,
                only: %i[show edit update destroy]

  def index
    authorize Property, :index?

    @properties = policy_scope(Property)
                  .includes(:host, :neighborhood,
                            :amenities, :listings)
                  .order(created_at: :desc)
  end

  def show
    authorize @property

    @reviews = @property.reviews.includes(
      visit: { application: :seeker }
    )
  end

  def new
    @property = Property.new(host: current_user)
    authorize @property
  end

  def create
    @property = Property.new(property_params)
    @property.host = current_user

    authorize @property

    if @property.save
      redirect_to @property,
                  notice: "Property created successfully."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @property
  end

  def update
    authorize @property

    if @property.update(property_params)
      redirect_to @property,
                  notice: "Property updated successfully."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @property

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
                .includes(:host, :neighborhood,
                          :amenities, :listings)
                .find(params[:id])
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
