class HomeController < ApplicationController
  allow_unauthenticated_access only: :index
  def index
    @listings = Listing.published
                       .includes(property: :neighborhood)
                       .order(created_at: :desc)
                       .limit(3)
  end
end