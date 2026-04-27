class UserMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.welcome_email.subject
  #
  def welcome_email(user)
    @user = user
    @login_url = new_user_session_url
    mail(
      to: user.email,
      subject: 'Welcome to Kanban Board!'
    )
  end
end
