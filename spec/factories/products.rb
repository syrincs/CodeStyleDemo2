# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product do
    title { Faker::Commerce.product_name }
    manufacturer 'Apple'
    description { Faker::Lorem.paragraph(10) }
    price { rand(1..100.00) }
    condition :new
    auction_duration 1.day / 1.hour # 1 day in hours
    user
    category

    before(:create) do |product|
      product.ships_from_address = product.user.address
    end

    trait :with_empty_order do
      after(:create) do |product|
        product.build_order.save(validate: false)
      end
    end

    trait :sold do
      sold true
    end

    trait :long_stay do
      auction_duration 30.days / 1.hour # 30 days in hours
    end
  end
end
