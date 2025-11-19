FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }
    admin { false }

    trait :admin do
      admin { true }
    end

    trait :with_tasks do
      transient do
        tasks_count { 3 }
      end

      after(:create) do |user, evaluator|
        create_list(:task, evaluator.tasks_count, assignee: user)
      end
    end
  end
end