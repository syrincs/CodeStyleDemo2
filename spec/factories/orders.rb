# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :order do
    transient do
      seller nil
      buyer nil
    end

    product
    user
    price_cents { product.price_cents - (product.price_cents * rand(0.05..0.2).round(2)) } # product price - 5-20%

    after(:build) do |order, evaluator|
      order.buyer = evaluator.buyer if evaluator.buyer
      order.product.seller = evaluator.seller if evaluator.seller
    end

    trait :paid do
      transient do
        paid_at nil
      end
      status :paid
      association :product, :sold
      after :create do |order, evaluator|
        charge = Charge.create! order: order, amount_cents: order.price_cents, user: order.buyer, created_at: evaluator.paid_at
        charge.transactions.create! amount_cents: order.price_cents, status: :success, href: '1'
      end
    end

    trait :shipped do
      status :shipped
      association :product, :sold
    end

    trait :delivered do
      status :delivered
      association :product, :sold
    end

    trait :returned do
      status :returned
      association :product, :sold
    end
  end
end
