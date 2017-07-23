require 'rails_helper'

describe ProductMessageMailer do
  describe 'created' do
    let(:order) { create(:order) }
    subject(:mail) { described_class.created(message.id) }

    context 'when buyer sends message to the seller' do
      let(:message) { create :message, product: order.product, sender: order.buyer, recipient: order.seller }

      specify do
        expect(mail.subject).to eq('You have new message from buyer')
      end

      it 'sends to seller email' do
        expect(mail.to).to eq([order.seller.email])
      end

      it 'sends from admin@1bid1.com' do
        expect(mail.from).to eq(['team@1bid1.com'])
      end

      it 'renders message url' do
        expect(mail.body.encoded).to include(dashboard_message_path(id: message.id))
      end
    end
  end
end
