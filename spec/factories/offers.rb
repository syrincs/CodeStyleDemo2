# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :offer do
    user
    product nil
    amount do
      if product
        rand(1..product.price.to_f)
      else
        rand(1..100)
      end
    end

    trait :with_product do
      product
    end
  end
end
