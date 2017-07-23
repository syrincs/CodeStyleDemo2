# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.include Sorcery::TestHelpers::Rails::Controller, type: :controller
  config.include Sorcery::TestHelpers::Rails::Integration, type: :feature

  config.before type: :controller do
    request.env['HTTP_REFERER'] = 'http://test.com/back' # to be able to test redirect_to :back
  end
  config.before type: :controller do
    request.env['mobvious.device_type'] = :desktop
  end
  config.before :each do
    Chewy.massacre
  end
  config.before :suite do
    Chewy.strategy(:bypass)
  end

  config.before(:suite) do
    begin
      DatabaseCleaner.start
      FactoryGirl.lint
    ensure
      DatabaseCleaner.clean_with(:truncation)
    end
  end

  config.around stripe: true do |example|
    StripeMock.start
    example.run
    StripeMock.stop
  end
end
