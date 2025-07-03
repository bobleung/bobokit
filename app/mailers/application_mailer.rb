class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("FROM_EMAIL", "noreply@mylocums.uk")
  layout "mailer"
end
