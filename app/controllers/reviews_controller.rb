
class ReviewsController < ApplicationController
  before_action :set_visit

  def new
    return unless can_review?

    @review = @visit.build_review
  end

  def create
    return unless can_review?

    @review = @visit.build_review(review_params)

    if @review.save
      redirect_to property_path(@visit.application.listing.property),
                  notice: "Review submitted successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_visit
    @visit = Visit.includes(application: { listing: :property })
                  .find(params[:visit_id])
  end

  def can_review?
    unless @visit.application.seeker_id == current_user.id &&
           @visit.completed? &&
           !@visit.review.present?

      redirect_to applications_path,
                  alert: "You cannot review this visit."
      return false
    end

    true
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
