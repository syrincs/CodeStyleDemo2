require 'rails_helper'

RSpec.describe StripeBillingManager, stripe: true do
  let!(:performer) { create :buyer }
  let(:manager) { described_class.new(performer) }

  before do
    manager.create_customer_profile(force: true)
  end

  describe '#create_credit_card' do
    subject { manager.create_credit_card(params) }

    context 'with stripe_token' do
      let(:params) { attributes_for(:raw_stripe_credit_card) }

      specify { expect { subject }.to change { performer.credit_cards.count }.from(0).to(1) }

      it 'returns created credit card' do
        credit_card = subject
        expect(performer.credit_cards).to include credit_card
      end
      it 'assigns token from gateway to credit card' do
        expect(subject.token).to eql params[:stripe_token]
      end
      context 'when credit card is the first' do
        it 'makes credit card default' do
          expect(subject.default_card).to be_truthy
        end
      end
      context 'when default_card is passed to the method' do
        let!(:first_cc) { manager.create_credit_card(params) }
        let(:params) { attributes_for(:raw_stripe_credit_card, default_card: true) }
        it 'makes credit card default' do
          expect(subject.default_card).to be_truthy
          expect(first_cc.reload.default_card).to be_falsey
        end
      end
    end

    context 'when params is empty' do
      let(:params) { Hash.new }
      specify { expect { subject }.to raise_error 'Please select payment method' }
    end

    context 'when stripe token is empty' do
      let(:params) { attributes_for(:raw_stripe_credit_card, stripe_token: '') }
      specify { expect { subject }.to raise_error 'Token cannot be blank, please try again' }
    end
  end
end
