RSpec.configure do |config|
  config.after(:each) do
    Timecop.return
  end

  config.around(:each, freeze: ->(value) { value.present? }) do |example|
    time = example.metadata[:freeze]
    time = case time
    when Time
      time
    when Date
      # We can't use Date#to_time because it doesn't account for timezones
      time.beginning_of_day
    when String
      Time.zone.parse(time)
    else
      Time.zone.now
    end
    Timecop.freeze(time) { example.run }
  end

  config.around(:each, travel: ->(value) { value.present? }) do |example|
    time = example.metadata[:travel]
    time = case time
    when Time
      time
    when Date
      time.beginning_of_day
    when String
      Time.zone.parse(time)
    else
      raise 'Invalid travel option specified'
    end
    Timecop.travel(time) { example.run }
  end
end
