# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :activity do
    trackable_id 1
    trackable_type "MyString"
    text "MyString"
    created_at "2014-12-22 15:27:29"
  end
end
