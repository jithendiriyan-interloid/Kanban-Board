FactoryBot.define do
  factory :user do
    sequence(:email) { |number| "user#{number}@example.com" }
    password { "Password1!" }
    password_confirmation { password }
    confirmed_at { Time.current }
    role { :member }

    trait :with_profile do
      phone_number { "9876543210" }
      alternate_email { "alternate@example.com" }
      address { "123 Kanban Street" }
    end

    trait :unconfirmed do
      confirmed_at { nil }
      confirmation_sent_at { Time.current }
    end

    trait :soft_deleted do
      deleted_at { Time.current }
    end
  end
end
