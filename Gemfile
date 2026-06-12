source "https://rubygems.org"

gem "rails", "~> 7.2.3"
gem "sprockets-rails"
gem "pg", "~> 1.5"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "aws-sdk-s3", require: false
gem "devise", "~> 5.0"
gem "rails-i18n", "~> 7.0"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "dotenv-rails"
  gem "rspec-rails", "~> 8.0"
  gem "factory_bot_rails"
  gem "faker"
  gem "pry-rails"
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "database_cleaner-active_record"
  gem "shoulda-matchers", "~> 8.0"
  gem "rspec_junit_formatter"
  gem "simplecov", require: false
  gem "bundler-audit", require: false
  gem "webmock"
end
