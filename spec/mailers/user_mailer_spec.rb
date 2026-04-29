require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "#welcome_email" do
    let(:user) { build_stubbed(:user, email: "member@example.com") }
    let(:mail) { described_class.welcome_email(user) }

    it "sends the email to the user" do
      expect(mail.to).to eq(["member@example.com"])
      expect(mail.subject).to eq("Welcome to Kanban Board!")
    end

    it "renders the welcome message and login URL" do
      expect(mail.body.encoded).to include("Welcome, member@example.com!")
      expect(mail.body.encoded).to include(new_user_session_url)
    end
  end
end
