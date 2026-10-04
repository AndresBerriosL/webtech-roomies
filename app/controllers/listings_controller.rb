class ListingsController < ApplicationController
  def index
    @listings = Listing
                .published
                .includes(property: :neighborhood)
                .order(created_at: :desc)
  end

  def show
    @listing = Listing
               .includes(property: [:neighborhood, :amenities])
               .find(params[:id])

    @reviews = @listing.property.reviews.includes(
      visit: { application: :seeker }
    )
  end
end