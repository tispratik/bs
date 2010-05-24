class UserMailer < ActionMailer::Base
  
  def project_invitation(email, sender)
    subject "Invitation to calendar project"
    recipients email
    from "notifications@example.com"
    body :email => email, :sender => sender
    content_type "text/html"
  end
  
  def event_invitation(email, sender)
    subject "Invitation to event"
    recipients email
    from "notifications@example.com"
    body :email => email, :sender => sender
    content_type "text/html"
  end
end
