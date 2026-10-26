
class AmenitiesController < ApplicationController
  before_action :set_amenity, only: %i[show edit update destroy]

  def index
    @amenities = Amenity.order(:name)
  end

  def show
  end

  def new
    @amenity = Amenity.new
  end

  def create
    @amenity = Amenity.new(amenity_params)

    if @amenity.save
      redirect_to @amenity, notice: "Amenity created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @amenity.update(amenity_params)
      redirect_to @amenity, notice: "Amenity updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @amenity.destroy
      redirect_to amenities_path,
                  notice: "Amenity deleted successfully."
    else
      redirect_to @amenity,
                  alert: "Amenity could not be deleted."
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
