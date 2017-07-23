# This is a custom matcher for verifying that payout has been created
# Usages:
#  expect { code }.to have_created_payout.for_order(order)
#  expect { code }.to have_created_payout(:system)
#  expect { code }.to have_created_payout(:seller)
#  expect { code }.to have_created_payout(:system).in_status(:success)
#  expect { code }.to have_created_payout(:system).in_status(:success).with_amount_cents(1000)
#
RSpec::Matchers.define :have_created_charge do |status|
  supports_block_expectations

  chain :for_order do |order|
    @order = order
  end

  chain :for_user do |user|
    @user = user
  end

  chain :with_amount_cents do |amount_cents|
    @amount_cents = amount_cents
  end

  match do |block|
    query = status ? Charge.with_status(status) : Charge
    query = query.where(order: @order)
    query = query.where(user: @user)
    query = query.where(amount_cents: @amount_cents) if @amount_cents

    old_count = query.count
    block.call
    new_count = query.count

    @count = new_count - old_count
    @count > 0
  end

  description do
    expected = 'have created charge'

    expected += " in status :#{status}" if status
    expected += " with amount of #{@amount_cents} cents" if @amount_cents
    expected += " for order #{@order}" if @order
    expected += " for user #{@user}" if @user
    expected
  end

  failure_message do
    "expected to #{description}, but created none"
  end

  failure_message_when_negated do
    "expected not to #{description}, but created one"
  end
end
