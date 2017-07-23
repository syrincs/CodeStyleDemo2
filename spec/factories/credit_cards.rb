# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :credit_card do
    brand 'visa'
    token '28385538'
    display_number 'XXXX-XXXX-XXXX-4242'
    month { Date.current.month }
    year { Date.current.year + 2 }
    default_card false
  end

  factory :raw_credit_card, class: ActiveMerchant::Billing::CreditCard do
    skip_create
    sequence(:name) { |n| "John #{n} Tester"}
    number '4242424242424242'
    month 10
    year 2020
    verification_value 123

    trait :american_express do
      number '378282246310005'
    end
  end

  factory :raw_stripe_credit_card, class: Hash do
    skip_create
    initialize_with { Hash.new attributes }

    stripe_token { Faker::Number.hexadecimal(12) }
    brand { %w(visa mastercard).sample }
    display_number { Faker::Finance.credit_card(:visa, :mastercard) }
    month { rand(1..12) }
    year { rand(Date.today.year..2040) }
    verification_value 123
  end
end
