require 'rails_helper'

RSpec.describe Offer do
  describe 'scope' do
    context 'wins' do
      let!(:product1) { create :product }
      let!(:product2) { create :product }
      let!(:user1) { create :user }
      let!(:user2) { create :user }

      subject { described_class.wins }

      it 'includes highest offers for each product' do
        offer1 = create(:offer, amount: 100, product: product1, user: user1)
        offer2 = create(:offer, amount: 100, product: product2, user: user2)

        highest_offer1 = create(:offer, amount: 200, product: product1, user: user1)
        highest_offer2 = create(:offer, amount: 200, product: product2, user: user2)

        expect(subject).not_to include offer1
        expect(subject).to include highest_offer1
        expect(subject).to include highest_offer2
      end

      it 'does not include same offers (by amount)' do
        offer1 = create(:offer, amount: 200, product: product1, user: user2)
        offer2 = create(:offer, amount: 200, product: product1, user: user1)
        offer3 = create(:offer, amount: 200, product: product2, user: user1)

        expect(subject).not_to include offer1
        expect(subject).not_to include offer2
        expect(subject).to include offer3
      end

      context 'when only one offer exists' do
        it 'includes the offer' do
          offer = create(:offer, amount: 200, product: product1, user: user1)
          expect(subject).to match_array [offer]
        end
      end
    end

    context 'outbid' do
      let!(:product1) { create :product }
      let!(:product2) { create :product }
      let!(:user1) { create :user }
      let!(:user2) { create :user }

      subject { described_class.outbid }

      it 'includes all offers wich have highest offers' do
        offer1 = create(:offer, amount: 100, product: product1, user: user1)
        offer2 = create(:offer, amount: 200, product: product1, user: user2)
        offer3 = create(:offer, amount: 300, product: product2, user: user1)
        offer4 = create(:offer, amount: 400, product: product2, user: user2)

        highest_offer1 = create(:offer, amount: 1000, product: product1, user: user1)
        highest_offer2 = create(:offer, amount: 1000, product: product2, user: user2)

        expect(subject).to match_array [offer1, offer2, offer3, offer4]
      end

      it 'includes same offers (by amount)' do
        offer1 = create(:offer, amount: 200, product: product1, user: user2)
        offer2 = create(:offer, amount: 200, product: product1, user: user1)
        offer3 = create(:offer, amount: 200, product: product2, user: user1)
        offer4 = create(:offer, amount: 200, product: product2, user: user2)

        highest_offer = create(:offer, amount: 500, product: product1, user: user1)
        highest_offer = create(:offer, amount: 500, product: product2, user: user2)

        expect(subject).to match_array [offer1, offer2, offer3, offer4]
      end

      context 'when two offer exist' do
        it 'includes lower one' do
          offer1 = create(:offer, amount: 200, product: product1, user: user2)
          highest_offer = create(:offer, amount: 500, product: product1, user: user1)

          expect(subject).to match_array [offer1]
        end
      end

      context 'when only one offer exists' do
        it 'does not include the offer' do
          offer = create(:offer, amount: 200, product: product1, user: user1)
          expect(subject).to be_empty
        end
      end
    end

    context 'not_rejected' do
      subject { described_class.not_rejected }

      it 'includes both pending and accepted offers' do
        pending_offer = create :offer, :with_product, accepted: nil
        accepted_offer = create :offer, :with_product, accepted: true
        expect(subject).to match_array [pending_offer, accepted_offer]
      end
    end
  end
end
