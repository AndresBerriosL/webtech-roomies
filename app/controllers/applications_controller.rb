class ApplicationsController < ApplicationController
  def index
    @applications = Application
                    .includes(:seeker, listing: { property: :neighborhood })
                    .order(created_at: :desc)
  end

  def show
    @application = Application
                   .includes(
                     :seeker,
                     :visits,
                     listing: { property: :neighborhood }
                   )
                   .find(params[:id])
  end
end