ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'simplecov'
require 'rspec/example_steps'
require 'shoulda-matchers'
require 'capybara/rspec'
require 'capybara/email/rspec'
require 'webmock/rspec'
require 'database_cleaner'
require 'capybara/feature_helpers'
require 'factory_girl'

SimpleCov.start

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|

  config.include Capybara::DSL
  config.include FactoryGirl::Syntax::Methods

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, type: :feature) do
    driver_shares_db_connection_with_specs = Capybara.current_driver == :rack_test
    DatabaseCleaner.strategy = :truncation if !driver_shares_db_connection_with_specs
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end
end

def stub_price(price, options={})
  $redis.del(:exchange_rate)
  response_data = {}
  ExchangeRateService::CURRENCIES.each do |currency|
    this_price = options[currency].present? ? options[currency] : price
    response_data[currency.upcase] = this_price
  end
  currencies = ExchangeRateService::CURRENCIES.map { |currency| currency.upcase }.join(',')
  stub_request(:get, "https://min-api.cryptocompare.com/data/price?fsym=DASH&tsyms=#{currencies}").to_return(
    status: 200,
    body: response_data.to_json,
    headers: {}
  )
end
