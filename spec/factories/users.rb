FactoryGirl.define do
  sequence :user_email do |n|
    "person#{n}@example.com"
  end
  sequence :user_name do |n|
    "user#{n}"
  end

  factory :user, aliases: [:buyer, :seller] do
    transient do
      address 'Address 1'
    end

    email { |n| generate(:user_email) }
    username { |n| generate(:user_name) }
    first_name 'John'
    last_name 'Tester'
    password 'secret'
    salt 'asdasdastr4325234324sdfds'
    billing_token '31382226'
    crypted_password Sorcery::CryptoProviders::BCrypt.encrypt('secret', 'asdasdastr4325234324sdfds')

    after(:create) do |user, evaluator|
      create(:address, addressable: user, address1: evaluator.address, default_address: true)
    end
  end
end
