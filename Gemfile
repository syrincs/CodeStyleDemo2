source 'https://rubygems.org'

gem 'rails', '~> 4.2'

# DB
gem 'pg'                                                    # ORM
gem 'paranoia'

# Auth
gem 'sorcery', github: 'webgago/sorcery'                    # Authentication
gem 'cancancan', '~> 1.8'                                   # Authorization
gem 'rolify'                                                # Roles

# Assets
gem 'slim-rails'                                            # Compiles to HTML
gem 'sass-rails', '~> 4.0.3'                                # Compiles to CSS
gem 'bootstrap-sass', '~> 3.3.5'                            # Frontend Styling Framework
gem 'bourbon'                                               # Scss helpers
gem 'font-awesome-sass'                                     # Font Awesome
gem 'coffee-rails', '~> 4.0.0'                              # Compiles to Javascript
gem 'jquery-rails'                                          # Jquery
gem 'jquery-ui-rails'                                       # Jquery UI
gem 'select2-rails'                                         # Pretty Dropdown Menu
gem 'chartkick'                                             # JS Charts
gem 'jbuilder', '~> 2.0'                                    # JSON
gem 'uglifier', '>= 1.3.0'                                  # Compress and Minify Assets
gem 'therubyracer', platforms: :ruby                        # JS runtime
gem 'sanitize'                                              # HTML and CSS sanitizer for user-input

gem 'simple_form', '~> 3.1.0'                               # Simple Forms
gem 'carmen-rails'                                          # Country Dropdown
gem 'kaminari', '~> 0.15.1'                                 # Pagination

# Pages
gem 'gaffe'                                                 # 404, 422, 500 error pages
gem 'high_voltage', '~> 2.4.0'                              # Static Pages

# Urls
gem 'friendly_id', '~> 5.0.3'                               # Pretty URLS
gem 'bitly'                                                 # URL shortener

# Background Jobs
gem 'sidekiq'                                               # Delayed Jobs
gem 'redis'
gem 'redis-namespace'
gem 'sidekiq-failures'
gem 'whenever', require: false                              # Cron jobs
gem 'clockwork', require: false                             # Jobs scheduling
gem 'clockworkd'

# Payments
gem 'activemerchant'
gem 'stripe'
gem 'money-rails'                                           # Currency and Conversions

gem 'twilio-ruby'

# Seo
gem 'meta-tags', require: 'meta_tags'                       # SEO Meta Data
gem 'sitemap_generator'                                     # Sitemap Generator

# Images managing
gem 'cloudinary', github: 'onebidone/cloudinary_gem'        # Image Upload
gem 'carrierwave', github:'carrierwaveuploader/carrierwave' # Image Uploader
gem 'carrierwave-base64'
gem 'gravatar_image_tag'                                    # Gravatar User Pictures
gem 'jquery-fileupload-rails'

gem 'noty-rails'                                            # Growl Notifications
gem 'rollbar'                                               # Errors
gem 'dotenv', '~> 0.11.1'
gem 'dotenv-deployment', require: 'dotenv/deployment'       # Automatic Vars in Production/Staging

gem 'acts-as-taggable-on', '~> 3.2.1'                       # Tagging
gem 'cocoon', '~> 1.2.6'                                    # Nested Fields
gem 'html_truncator'                                        # Propper Truncation
gem 'draper', '~> 1.3'                                      # View Decorators
gem 'chronic'                                               # Datetime Helper
gem 'chewy'                                                 # Search

gem 'recaptcha', '~> 0.4.0', require: 'recaptcha/rails'     # Re-captcha
gem 'enumerize'                                             # Enumerizations
gem 'simple-useragent'                                      # Mobile workarounds

gem 'daemons'
gem 'rails_autolink'
gem 'email_validator'

gem 'sinatra', require: false                               # Web interface of Sidekiq processes

gem 'utf8_enforcer_workaround'
gem 'easypost'                                              # Shipping API
gem 'koala', '~> 2.2'

group :doc do
  gem 'sdoc', '~> 0.4.0'                                    # Documentation
end


group :development, :test, :staging do
  gem 'capybara'                                            # Integration Testing
  gem 'factory_girl_rails'                                  # Testing Factories
  gem 'rspec', '~> 3.0.0.beta2'                             # Test Framework
  gem 'rspec-rails', '~> 3.0.0.beta'                        # Test Helpers
  gem 'rspec-collection_matchers'
  gem 'guard-rspec', '~> 4.2.8'                             # Automatic Testing
  gem 'minitest', '~> 5.3.3'                                # Test Framework
  gem 'shoulda-matchers'                                    # Quicker Rspec Matchers
  gem 'faker'                                               # Fake Data for Tests
  gem 'vcr'
  gem 'webmock', require: false
  gem 'timecop'                                             # Testing time-related stuff
end

group :development, :staging do
  gem 'quiet_assets', '>= 1.0.2'                            # Log Tailing

  gem 'spring-commands-rspec'
  gem 'foreman', '~> 0.63.0'                                # Production Vars
  gem 'pry-rails'                                           # Debugger
end

group :development do
  gem 'byebug'
  gem 'letter_opener'
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  gem 'database_cleaner'                                    # Test Database Cleaner
  gem 'simplecov', require: false                           # Test Helper
  gem 'stripe-ruby-mock', '~> 2.3.1', require: 'stripe_mock'
end

gem 'puma', '2.14.0'
gem 'mobvious'
gem 'intercom-rails'
