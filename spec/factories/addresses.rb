# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :address do
    sequence(:first_name) { |n| "John #{n}" }
    last_name 'Tester'
    address1 'Address 1'
    address2 'Address 2'
    city 'Los Angeles'
    state 'California'
    zip_code '12345'
  end
end
