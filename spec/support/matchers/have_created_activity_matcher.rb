# This is a custom matcher for verifying that payout has been created
# Usages:
#  expect { code }.to have_created_activity('some message for activity').for(trackable)
#
RSpec::Matchers.define :have_created_activity do |message|
  supports_block_expectations

  chain :for do |trackable|
    @trackable = trackable
  end

  match do |block|
    query = message ? Activity.where(text: message.to_s) : Activity
    query = query.where(trackable: @trackable) if @trackable.is_a?(ActiveRecord::Base)

    old_count = query.count
    block.call
    new_count = query.count

    @count = new_count - old_count
    @count > 0
  end

  description do
    expected = if message
      "have created activity with message: #{message}"
    else
      'have created activity'
    end

    expected += " for #{@trackable.class}##{@trackable.id}" if @trackable
    expected
  end

  failure_message do
    "expected to #{description}, but created none"
  end

  failure_message_when_negated do
    "expected not to #{description}, but created one"
  end
end
