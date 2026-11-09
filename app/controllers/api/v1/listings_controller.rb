
module Api
  module V1
    class ListingsController < ActionController::API
      def index
        listings = Listing.published
                          .joins(property: :neighborhood)
                          .includes(property: :neighborhood)

        if params[:max_rent].present?
          max_rent = BigDecimal(params[:max_rent].to_s)
          raise ArgumentError if max_rent.negative?

          listings = listings.where(
            "listings.monthly_rent <= ?", max_rent
          )
        end

        if params[:neighborhood_id].present?
          neighborhood_id = Integer(
            params[:neighborhood_id].to_s, 10
          )
          raise ArgumentError if neighborhood_id <= 0

          listings = listings.where(
            properties: { neighborhood_id: neighborhood_id }
          )
        end

        if params[:furnished].present?
          furnished = params[:furnished].to_s
          raise ArgumentError unless %w[true false].include?(furnished)

          listings = listings.where(
            furnished: furnished == "true"
          )
        end

        listings = listings.order(created_at: :desc).limit(100)
        records = listings.to_a

        render json: {
          data: records.map { |listing| listing_data(listing) },
          meta: {
            count: records.size
          }
        }, status: :ok

      rescue ArgumentError, TypeError
        render json: {
          error: {
            code: "invalid_filter",
            message: "One or more filters are invalid."
          }
        }, status: :bad_request
      end

      def show
        listing = Listing.published
                         .includes(property: :neighborhood)
                         .find_by(id: params[:id])

        unless listing
          render json: {
            error: {
              code: "not_found",
              message: "Listing not found."
            }
          }, status: :not_found
          return
        end

        render json: {
          data: listing_data(listing)
        }, status: :ok
      end

      private

      def listing_data(listing)
        {
          id: listing.id,
          monthly_rent: listing.monthly_rent.to_f,
          deposit: listing.deposit.to_f,
          availability_date: listing.availability_date,
          minimum_stay: listing.minimum_stay,
          furnished: listing.furnished?,
          private_bathroom: listing.private_bathroom?,
          description: listing.description&.to_plain_text,
          property: {
            type: listing.property.property_type,
            neighborhood: {
              id: listing.property.neighborhood.id,
              name: listing.property.neighborhood.name
            }
          },
          url: "/listings/#{listing.id}"
        }
      end
    end
  end
end
