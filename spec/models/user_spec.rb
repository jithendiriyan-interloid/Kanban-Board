require "rails_helper"

RSpec.describe User, type: :model do
  describe "factory" do
    it "builds a valid user" do
      expect(build(:user)).to be_valid
    end
  end

  describe "roles" do
    it "defaults to member" do
      expect(create(:user)).to be_member
    end

    it "supports owner and admin roles" do
      owner = create(:user, :owner)
      admin = create(:user, :admin)

      expect(owner).to be_owner
      expect(admin).to be_admin
    end
  end

  describe "validations" do
    it "requires password changes to include a special character" do
      user = build(:user, password: "Password12", password_confirmation: "Password12")

      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("must include at least one special character")
    end

    it "allows a blank alternate email" do
      user = build(:user, alternate_email: "")

      expect(user).to be_valid
    end

    it "requires alternate email to be valid when present" do
      user = build(:user, alternate_email: "not-an-email")

      expect(user).not_to be_valid
      expect(user.errors[:alternate_email]).to include("must be a valid email")
    end
  end

  describe "#profile_complete?" do
    it "returns true when all profile fields are present" do
      expect(build(:user, :with_profile)).to be_profile_complete
    end

    it "returns false when any profile field is missing" do
      expect(build(:user, phone_number: "9876543210", alternate_email: "alt@example.com")).not_to be_profile_complete
    end
  end

  describe "soft deletion" do
    it "marks the user as soft deleted" do
      user = create(:user)

      expect { user.soft_delete! }.to change { user.reload.deleted_at }.from(nil)
      expect(user).to be_soft_deleted
    end

    it "prevents soft-deleted users from authenticating" do
      user = create(:user, :soft_deleted)

      expect(user.active_for_authentication?).to be(false)
      expect(user.inactive_message).to eq(:deleted_account)
    end
  end
end
