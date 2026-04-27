class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("SMTP_USERNAME", "no-reply@kanban-board.local")
  layout "mailer"
end
