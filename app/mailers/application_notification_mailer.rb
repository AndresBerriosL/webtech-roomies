
class ApplicationNotificationMailer < ApplicationMailer
  def created
    application = params[:application]
    host = application.listing.property.host

    mail(
      to: host.email,
      subject: "Roomies - New application received"
    ) do |format|
      format.text do
        render plain: <<~MESSAGE
          Hello #{host.name},

          #{application.seeker.name} has applied to your room.

          Property: #{application.listing.property.address}

          View the application:
          #{application_url(application)}

          Roomies Team
        MESSAGE
      end
    end
  end

  def status_changed
    application = params[:application]
    seeker = application.seeker

    mail(
      to: seeker.email,
      subject: "Roomies - Application status updated"
    ) do |format|
      format.text do
        render plain: <<~MESSAGE
          Hello #{seeker.name},

          Your application status has changed.

          Property: #{application.listing.property.address}
          New status: #{application.status.humanize}

          View your application:
          #{application_url(application)}

          Roomies Team
        MESSAGE
      end
    end
  end
end
