require "rails_helper"

RSpec.describe "Users", type: :request do
  describe "GET /" do
    it "redirects guests to the sign-in page" do
      get root_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "shows the profile form for a signed-in user with an incomplete profile" do
      user = create(:user)
      sign_in user

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Complete your profile")
    end

    it "shows saved profile information when the profile is complete" do
      user = create(:user, :with_profile)
      sign_in user

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Profile information")
      expect(response.body).to include("9876543210")
      expect(response.body).to include("alternate@example.com")
    end
  end

  describe "PATCH /profile" do
    it "updates the current user's profile" do
      user = create(:user)
      sign_in user

      patch profile_path, params: {
        user: {
          phone_number: "1234567890",
          alternate_email: "profile@example.com",
          address: "456 Board Lane"
        }
      }

      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("Your profile information was saved.")
      expect(user.reload).to have_attributes(
        phone_number: "1234567890",
        alternate_email: "profile@example.com",
        address: "456 Board Lane"
      )
    end

    it "renders the profile form again when profile data is invalid" do
      user = create(:user, alternate_email: "old@example.com")
      sign_in user

      patch profile_path, params: {
        user: {
          phone_number: "1234567890",
          alternate_email: "invalid-email",
          address: "456 Board Lane"
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Alternate email must be a valid email")
      expect(user.reload.alternate_email).to eq("old@example.com")
    end
  end

  describe "DELETE /remove_avatar" do
    it "removes the current user's avatar" do
      user = create(:user)
      user.avatar.attach(
        io: File.open(Rails.root.join("app/assets/images/default_avatar.jpg")),
        filename: "default_avatar.jpg",
        content_type: "image/jpeg"
      )
      sign_in user

      delete remove_avatar_path

      expect(response).to redirect_to(root_path(edit_profile: true))
      expect(flash[:notice]).to eq("Your avatar was removed.")
      expect(user.reload.avatar).not_to be_attached
    end
  end

  describe "POST /profile/skip" do
    it "skips the profile form for the session" do
      user = create(:user)
      sign_in user

      post skip_profile_path
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("You can add your profile information later.")

      follow_redirect!
      expect(response.body).to include("Profile information")
      expect(response.body).not_to include("Complete your profile")
    end
  end

  describe "DELETE /profile" do
    it "soft deletes the current user and signs them out" do
      user = create(:user)
      sign_in user

      delete delete_profile_path

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:notice]).to eq("Your account has been deleted.")
      expect(user.reload).to be_soft_deleted
    end
  end
end
