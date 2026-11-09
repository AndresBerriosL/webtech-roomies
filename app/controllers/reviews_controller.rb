
class ReviewsController < ApplicationController
  before_action :set_visit, only: %i[new create]

  def new
    @review = Review.new(visit: @visit)
    authorize @review
  end

  def create
    @review = Review.new(
      review_params.merge(visit: @visit)
    )

    authorize @review

    if @review.save
      redirect_to property_path(
        @visit.application.listing.property
      ), notice: "Review submitted successfully."
    else
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    @review = Review.includes(
      visit: { application: { listing: :property } }
    ).find(params[:id])

    authorize @review

    property = @review.visit.application.listing.property

    if @review.destroy
      redirect_to property_path(property),
                  status: :see_other,
                  notice: "Review deleted successfully."
    else
      redirect_to property_path(property),
                  status: :see_other,
                  alert: "Review could not be deleted."
    end
  end

  private

  def set_visit
    @visit = Visit.includes(
      application: { listing: :property }
    ).find(params[:visit_id])
  end

  def review_params
    params.require(:review).permit(
      :rating,
      :comment
    )
  end
end
