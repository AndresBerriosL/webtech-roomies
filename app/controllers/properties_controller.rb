class PropertiesController < ApplicationController
  def index
    @properties = Property
                  .includes(:host, :neighborhood, :amenities, :listings)
                  .order(created_at: :desc)
  end

  def show
    @property = Property
                .includes(:host, :neighborhood, :amenities, :listings)
                .find(params[:id])

    @reviews = @property.reviews.includes(
      visit: { application: :seeker }
    )
  end
end