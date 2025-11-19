FactoryBot.define do
  factory :task do
    title { Faker::Lorem.sentence(word_count: 5) }
    description { Faker::Lorem.paragraph }
    status { :pending }
    association :project

    trait :pending do
      status { :pending }
    end

    trait :in_progress do
      status { :in_progress }
    end

    trait :completed do
      status { :completed }
    end

    trait :archived do
      status { :archived }
    end

    trait :with_assignee do
      association :assignee, factory: :user
    end
  end
end