require 'rails_helper'

RSpec.describe UserLifecycleManager do
  let(:manager) { described_class.new }

  describe '#invite' do
    let(:user_params) { {first_name: 'John', last_name: 'Connor', email: 'john.connor@future.net', assign_role: 'manager', invitation_message: 'Invitation message!'} }
    let(:invite_form) { Forms::InviteUser.new(User.new, user_params) }
    subject { manager.invite(invite_form) }

    it 'creates a user' do
      expect { subject }.to change(User, :count).from(0).to(1)
    end

    it 'sends email with further instructions' do
      expect { subject }.to deliver_mail(UserMailer, :invite_email).with(Integer, 'Invitation message!')
    end

    it 'assigns given role instantly' do
      expect(subject.reload).to have_role(:manager)
    end
  end
end
