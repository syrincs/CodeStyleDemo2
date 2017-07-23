# This is a custom matcher for verifying that payout has been created
# Usages:
#  expect { code }.to have_created_transaction(:success)
#  expect { code }.to have_created_transaction(:failed).for(payout)
#  expect { code }.to have_created_transaction(:success).for(payout).with_amount_cents(1000)
#  expect { code }.to have_created_transaction(:success).for(payout).with_amount_cents(1000).with_payable(bank_account)
#
RSpec::Matchers.define :have_created_transaction do |status|
  supports_block_expectations

  chain :for do |transactionable|
    @transactionable = transactionable
  end

  chain :with_amount_cents do |amount_cents|
    @amount_cents = amount_cents
  end

  chain :with_payable do |payable|
    @payable = payable
  end

  match do |block|
    query = status ? Transaction.where(status: status) : Transaction
    query = query.where(transactionable: @transactionable) if @transactionable.is_a?(ActiveRecord::Base)
    query = query.where(amount_cents: @amount_cents) if @amount_cents
    query = query.where(payable: @payable) if @payable

    old_count = query.count
    block.call
    new_count = query.count

    @count = new_count - old_count
    @count > 0
  end

  description do
    expected = 'have created transaction'
    expected += " in status :#{status}" if status
    expected += " with amount of #{@amount_cents} cents" if @amount_cents
    expected += " for #{@transactionable}" if @transactionable
    expected += " with payable #{@payable}" if @payable
    expected
  end

  failure_message do
    "expected to #{description}, but created none"
  end

  failure_message_when_negated do
    "expected not to #{description}, but created one"
  end
end
