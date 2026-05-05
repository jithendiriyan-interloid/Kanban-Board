require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "welcome_email" do
    user = Struct.new(:email).new("to@example.org")
    mail = UserMailer.welcome_email(user)

    assert_equal "Welcome to Kanban Board!", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ ENV.fetch("SMTP_USERNAME", "no-reply@kanban-board.local") ], mail.from
    assert_match "Welcome, to@example.org!", mail.body.encoded
  end
end
