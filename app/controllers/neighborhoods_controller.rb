
class NeighborhoodsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  before_action :set_neighborhood,
                only: %i[show edit update destroy]

  def index
    authorize Neighborhood, :index?
    @neighborhoods = policy_scope(Neighborhood).order(:name)
  end

  def show
    authorize @neighborhood

    @properties = policy_scope(Property)
                  .where(neighborhood_id: @neighborhood.id)
                  .includes(:listings)
  end

  def new
    @neighborhood = Neighborhood.new
    authorize @neighborhood
  end

  def create
    @neighborhood = Neighborhood.new(neighborhood_params)
    authorize @neighborhood

    if @neighborhood.save
      redirect_to @neighborhood,
                  notice: "Neighborhood created successfully."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @neighborhood
  end

  def update
    authorize @neighborhood

    if @neighborhood.update(neighborhood_params)
      redirect_to @neighborhood,
                  notice: "Neighborhood updated successfully."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @neighborhood

    if @neighborhood.destroy
      redirect_to neighborhoods_path,
                  status: :see_other,
                  notice: "Neighborhood deleted successfully."
    else
      redirect_to @neighborhood,
                  status: :see_other,
                  alert: @neighborhood.errors.full_messages.to_sentence
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
