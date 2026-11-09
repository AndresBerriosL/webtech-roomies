
class ReportsController < ApplicationController
  before_action :set_listing, only: %i[new create]

  def index
    authorize Report, :index?

    @reports = policy_scope(Report)
      .includes(:reporter, listing: { property: :neighborhood })
      .order(created_at: :desc)
  end

  def new
    @report = @listing.reports.build(reporter: current_user)
    authorize @report
  end

  def create
    @report = @listing.reports.build(report_params)
    @report.reporter = current_user
    @report.status = :pending

    authorize @report

    if @report.save
      redirect_to listing_path(@listing),
                  notice: "Report submitted successfully."
    else
      render :new, status: :unprocessable_content
    end
  end

  def resolve
    @report = Report.find(params[:id])
    authorize @report

    if @report.update(status: :resolved)
      redirect_to reports_path,
                  notice: "Report resolved successfully."
    else
      redirect_to reports_path,
                  alert: @report.errors.full_messages.to_sentence
    end
  end

  private

  def set_listing
    @listing = policy_scope(Listing).find(params[:listing_id])
  end

  def report_params
    params.expect(report: [:reason])
  end
end
