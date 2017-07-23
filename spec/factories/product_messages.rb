# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product_message do
    product nil
    sender nil
    is_read false
    body "MyText"
    created_at "2014-09-10 13:39:05"
  end
end
