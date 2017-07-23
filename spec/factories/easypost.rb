FactoryGirl.define do
  factory :easypost_tracker, class: 'EasyPost::Tracker' do
    sequence(:id) { "trk_#{('A'..'z').to_a.sample(8).join}" }
    status 'in_transit'
    tracking_code 'E700000007'

    initialize_with { EasyPost::Tracker.construct_from(attributes) }
    to_create { }
  end

  factory :easypost_postage_label, class: 'EasyPost::PostageLabel' do
    sequence(:id) { "pst_#{('A'..'z').to_a.sample(8).join}" }
    label_url 'http://assets.geteasypost.com/postage_labels/labels/lUoagDx.png'

    initialize_with { EasyPost::PostageLabel.construct_from(attributes) }
    to_create { }
  end

  factory :easypost_rate, class: 'EasyPost::Rate' do
    sequence(:id) { "rte_#{('A'..'z').to_a.sample(8).join}" }
    rate '5.5'
    delivery_days '4'
    carrier 'USPS'
    service 'Priority'
    initialize_with { EasyPost::Rate.construct_from(attributes) }
    to_create { }
  end

  factory :easypost_shipment, class: 'EasyPost::Shipment' do
    sequence(:id) { "shp_#{('A'..'z').to_a.sample(8).join}" }
    tracker factory: :easypost_tracker
    postage_label factory: :easypost_postage_label

    initialize_with { EasyPost::Shipment.construct_from(attributes) }
    to_create { }

    after(:build) do |shipment, evaluator|
      shipment.refresh_from({rates: create_list(:easypost_rate, 3, shipment_id: shipment.id)}, shipment.api_key)
    end
  end
end
