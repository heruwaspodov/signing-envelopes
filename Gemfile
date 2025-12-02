# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

source 'https://gems.contribsys.com/' do
  gem 'sidekiq-pro'
end

ruby '3.0.7'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.6', '>= 6.1.6.1'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use Puma statsd as datadog metric collector
gem 'puma-plugin-statsd'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6.0.0'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.4', '>= 5.4.3'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
gem 'image_processing', '~> 1.2'

# Active Storage validations
gem 'active_storage_validations'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

# rubocop:disable Metrics/BlockLength
group :production, :development, :staging, :sandbox do
  gem 'active_hash'
  gem 'activerecord-analyze'
  gem 'aws-sdk-s3'
  gem 'blind_index'
  gem 'bump'
  gem 'caxlsx'
  gem 'circuitbox'
  gem 'counter_culture'
  gem 'csv', '~> 3.2', '>= 3.2.6'
  gem 'datadog', '~> 2.0', require: 'datadog/auto_instrument'
  gem 'dogstatsd-ruby', '5.4.0'
  gem 'flipper-redis'
  gem 'flipper-ui'
  gem 'jbuilder'
  gem 'kaminari'
  gem 'lockbox'
  gem 'pundit'
  gem 'rack-cors'
  gem 'ransack'
  gem 'remote_syslog_logger'
  gem 'rest-client', '~> 2.1'
  gem 'rexml'
  gem 'rswag-api'
  gem 'rswag-ui'
  gem 'rubyzip'
  gem 'sidekiq'
  gem 'sidekiq-cron'
  gem 'sidekiq-unique-jobs'
  gem 'turnout'
  gem 'uuidtools'
  gem 'wkhtmltopdf-binary'
end
# rubocop:enable Metrics/BlockLength

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'kramdown', '~> 2.4'
  gem 'parallel_tests'
  gem 'pry-rails'
  gem 'rouge'
  gem 'rswag-specs'
  gem 'yard'
  gem 'yard-markdown'
  gem 'yard-rails'
end

group :test do
  gem 'database_cleaner-active_record'
  gem 'rspec-retry'
  gem 'rspec-sidekiq'
  gem 'shoulda-matchers', '~> 4.0'
  gem 'simplecov', require: false
  gem 'simplecov_json_formatter', '~> 0.1.2'
  gem 'timecop'
  gem 'webmock'
end

group :development do
  gem 'brakeman', '~> 5.1.1'
  gem 'listen', '~> 3.3'
  gem 'overcommit'
  gem 'pronto', '~> 0.11.0'
  gem 'pronto-flay', '~> 0.11.1'
  gem 'pronto-rubocop', '~> 0.11.3'
  gem 'rack-mini-profiler', '~> 2.3', '>= 2.3.3'
  gem 'rails_best_practices'
  gem 'rails-erd'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubycritic', require: false
  gem 'spring'
  gem 'squasher', '~> 0.7.3'
  gem 'web-console', '>= 4.2.0'
end

gem 'activeadmin'
gem 'activeadmin_addons'
gem 'active_record_union'
gem 'activestorage-aliyun'
gem 'active_storage_base64'
gem 'aliyun-sdk'
gem 'audited', '~> 5.0'
gem 'countries'
gem 'devise'
gem 'digest'
gem 'faker', '2.17.0'
gem 'flipper'
gem 'flock-notifier', github: 'mekari-engineering/flock-notifier', branch: 'dev-master'
gem 'googleauth', '~> 1.14'
gem 'health_bit'
gem 'hexapdf', '~> 0.46.0'
gem 'jsonapi-serializer'
gem 'jwt', '~> 2.2'
gem 'libreconv'
gem 'lograge', '~> 0.11.2'
gem 'mekari_sso', '~> 2.0', '>= 2.0.7'
gem 'mini_magick'
gem 'phonelib'
gem 'rails_param'
gem 'rmagick'
gem 'roo', '~> 2.9'
gem 'rqrcode', '~> 2.1', '>= 2.1.2'
gem 'ruby-filemagic'
gem 'searchkick'
gem 'slim'
gem 'strong_migrations'
gem 'wicked_pdf'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# for json schema validator
gem 'json-schema', '~> 2.2'
