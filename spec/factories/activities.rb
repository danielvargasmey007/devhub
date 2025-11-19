FactoryBot.define do
  factory :activity do
    action { "Task status updated" }
    association :record, factory: :task

    trait :for_task do
      association :record, factory: :task
    end

    trait :for_project do
      association :record, factory: :project
    end
  end
end