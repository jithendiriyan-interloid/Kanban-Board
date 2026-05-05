class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable, :timeoutable, :lockable
  # Role management using enum
  enum :role, { member: 0, owner: 1, admin: 2 }

  has_one_attached :avatar

  after_update_commit :send_welcome_email, if: :just_confirmed?

  # validations
  validates :email, presence: true, uniqueness: true
  validates :password,
    format: {
      with: /[!@#$%^&*(),.?":{}|<>]/,
      message: "must include at least one special character"
    },
    allow_blank: true
  validates :alternate_email,
    format: {
      with: Devise.email_regexp,
      message: "must be a valid email"
    },
    allow_blank: true

  def display_name
    [first_name, last_name].compact_blank.join(" ").presence || email
  end

  def profile_complete?
    first_name.present? && last_name.present? && phone_number.present? && address.present? && alternate_email.present?
  end

  def soft_deleted?
    deleted_at.present?
  end

  def soft_delete!
    update!(deleted_at: Time.current)
  end

  def active_for_authentication?
    super && !soft_deleted?
  end

  def inactive_message
    soft_deleted? ? :deleted_account : super
  end

  private

  def just_confirmed?
    saved_change_to_confirmed_at? && confirmed?
  end

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_now
  end
end
