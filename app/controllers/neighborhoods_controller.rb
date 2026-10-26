
class NeighborhoodsController < ApplicationController
  before_action :set_neighborhood, only: %i[show edit update destroy]

  def index
    @neighborhoods = Neighborhood.order(:name)
  end

  def show
    @properties = @neighborhood.properties.includes(:listings)
  end

  def new
    @neighborhood = Neighborhood.new
  end

  def create
    @neighborhood = Neighborhood.new(neighborhood_params)

    if @neighborhood.save
      redirect_to @neighborhood, notice: "Neighborhood created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @neighborhood.update(neighborhood_params)
      redirect_to @neighborhood, notice: "Neighborhood updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @neighborhood.destroy
      redirect_to neighborhoods_path, notice: "Neighborhood deleted successfully."
    else
      redirect_to @neighborhood,
                  alert: "Neighborhood could not be deleted."
    end
  end

  private

  def set_neighborhood
    @neighborhood = Neighborhood.find(params[:id])
  end

  def neighborhood_params
    params.require(:neighborhood).permit(:name)
  end
end
