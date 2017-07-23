# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :issue do
    subject 'Some reason'
    description 'Some description'
    order nil
  end
end
