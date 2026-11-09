
class AmenitiesController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  before_action :set_amenity,
                only: %i[show edit update destroy]

  def index
    authorize Amenity, :index?
    @amenities = policy_scope(Amenity).order(:name)
  end

  
  def show
    authorize @amenity

    @properties = policy_scope(Property)
      .where(id: @amenity.properties.select(:id))
      .includes(:listings)
      .order(:address)
  end


  def new
    @amenity = Amenity.new
    authorize @amenity
  end

  def create
    @amenity = Amenity.new(amenity_params)
    authorize @amenity

    if @amenity.save
      redirect_to @amenity,
                  notice: "Amenity created successfully."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @amenity
  end

  def update
    authorize @amenity

    if @amenity.update(amenity_params)
      redirect_to @amenity,
                  notice: "Amenity updated successfully."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @amenity

    if @amenity.destroy
      redirect_to amenities_path,
                  status: :see_other,
                  notice: "Amenity deleted successfully."
    else
      redirect_to @amenity,
                  status: :see_other,
                  alert: @amenity.errors.full_messages.to_sentence
    end
  end

  private

  def set_amenity
    @amenity = Amenity.find(params[:id])
  end

  def amenity_params
    params.require(:amenity).permit(:name)
  end
end
