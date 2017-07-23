# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message, class: 'ProductMessage' do
    product factory: :product
    sender { create :user }
    recipient { create :user }
    body 'Message'
  end
end
