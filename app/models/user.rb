class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable, :timeoutable, :lockable
  # Role management using enum
  enum :role, { member: 0, owner: 1, admin: 2 }

  # mailer
  after_create :send_welcome_email

  # validations
  validates :email, presence: true, uniqueness: true
  validates :password,
    length: { in: 6..12, too_long: "must be at most 12 characters" },
    format: {
      with: /[!@#$%^&*(),.?":{}|<>]/,
      message: "must include at least one special character"
    }

  private

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_later
  end
end
