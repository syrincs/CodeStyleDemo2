require 'rails_helper'

RSpec.describe User do
  describe 'Managed Stripe account' do
    context do "user with a stripe account"
      before do
        allow(Stripe::Account).to receive(:retrieve).and_return("acct_somefake_stripe_id")
        allow_any_instance_of(User).to receive(:update_stripe_account_attributes!).and_return(true)

        @user = create(:user, stripe_managed_account_id: "act_testest", dob: nil)
      end

      it "updates the stripe account if the DOB was changed" do
        @user.dob = 20.years.ago
        expect(@user).to receive(:update_stripe_account_attributes!).once
        @user.save!
      end

      it "does NOT update the stripe account if the bio was changed" do
        @user.bio = "This bio is something Stripe does not care about"
        expect(@user).to_not receive(:update_stripe_account_attributes!)
        @user.save!
      end

      it "updates the stripe account if the firstname name was changed" do
        @user.first_name = "Ernesto"
        expect(@user).to receive(:update_stripe_account_attributes!).once
        @user.save!
      end

      it "updates the stripe account if the lastname name was changed" do
        @user.first_name = "Santos"
        expect(@user).to receive(:update_stripe_account_attributes!).once
        @user.save!
      end
    end

    context do "user without a stripe account"
      let!(:user) { create(:user, stripe_managed_account_id: nil, dob: nil) }
      it "does not try to update Stripe account if the DOB was changed" do
        user.dob = 20.years.ago
        expect(user).to_not receive(:update_stripe_account_attributes!)
        user.save!
      end
    end
  end
end
