FactoryGirl.define do
  factory :question do
    title Faker::Hacker.say_something_smart
    description Faker::Lorem.paragraph

    trait :with_answer do
      after(:create) do |question|
        question.build_answer.save(validate: false)
      end
    end

    trait :not_valid do
      title nil
      description nil
    end

    trait :not_valid_without_title do
      title nil
      description Faker::Lorem.paragraph
    end

    trait :not_valid_without_description do
      title Faker::Hacker.say_something_smart
      description nil
    end
  end
end
