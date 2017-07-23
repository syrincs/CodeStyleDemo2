# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :bank_account do
    user
    account_number '000123456789'
    routing_number '110000000'
    name_on_account 'John Tester'
    phone_number '0912343413'
    address '1 Rodeo Drive'
    legal_entity_ssn_last_4 '1234'
    legal_entity_address1 '1 Rodeo Drive'
    legal_entity_city 'Los Angeles'
    legal_entity_postal_code '90210'
    legal_entity_state 'CA'
  end

  factory :raw_bank_account, class: BankAccount do
    skip_create
    user
    bank_name 'STRIPE TEST BANK'
    phone_number '0912343412'
    address 'Street 1, 123'
    account_number '000123456789'
    routing_number '110000000'
    name_on_account 'John Tester'
    legal_entity_ssn_last_4 '1234'
    legal_entity_address1 '1 Rodeo Drive'
    legal_entity_city 'Los Angeles'
    legal_entity_postal_code '90210'
    legal_entity_state 'CA'
  end
end
