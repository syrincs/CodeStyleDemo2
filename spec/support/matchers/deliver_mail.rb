RSpec::Matchers.define :deliver_mail do |mailer, method_name|
  supports_block_expectations

  match do |proc|
    @method = "#{mailer}##{method_name}"
    begin
      RSpec::Mocks.setup

      allow(mailer).to receive(method_name).with(any_args).and_call_original

      double = expect(mailer).to receive(method_name)
      double = double.exactly(@times).times if @times
      double = double.with(*@args) if @args
      double.and_call_original

      proc.call
      RSpec::Mocks.verify
      true
    rescue RSpec::Mocks::MockExpectationError => e
      @original_error = e
      false
    ensure
      @args = nil
      RSpec::Mocks::teardown
    end
  end

  chain :times do |times|
    @times = times
  end

  chain :with do |*args|
    @args = args
  end

  failure_message do |actual|
    "Expected block to deliver #{@method}, but it never did with original message: #{@original_error}"
  end

  failure_message_when_negated do |actual|
    "Block delivered #{@method}, but expected none"
  end

  description do
    "expect block to deliver #{@method}"
  end
end
