require 'rails_helper'

RSpec.describe Product do
  describe 'scopes' do
    context '.auction_not_finished' do
      subject { described_class.auction_not_finished }
      let!(:active_product) { create(:product) }
      let!(:finished_product) { create(:product, auction_finish_at: Date.yesterday) }

      it 'includes products' do
        expect(subject).to include active_product
      end

      it 'does not include finished products' do
        expect(subject).not_to include finished_product
      end
    end
  end
end
