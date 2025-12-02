# frozen_string_literal: true

require 'simplecov'
require 'simplecov_json_formatter'

SimpleCov.start do
  if ENV['CI']
    formatter SimpleCov::Formatter::JSONFormatter
  else
    formatter SimpleCov::Formatter::MultiFormatter.new([
                                                         SimpleCov::Formatter::HTMLFormatter,
                                                         SimpleCov::Formatter::JSONFormatter
                                                       ])
  end

  add_filter '/spec/'
  add_filter '/app/admin'
  add_filter '/lib/excels'
  add_filter '/lib/amazons'
  add_filter '/config'

  add_group 'Models',      'app/models'
  add_group 'Validates',   'app/validates'
  add_group 'Controllers', 'app/controllers'
  add_group 'Serializers', 'app/serializers'
  add_group 'Services',    'app/services'
  add_group 'Mailers',     'app/mailers'
  add_group 'Helpers',     'app/helpers'
  add_group 'Jobs',        'app/jobs'
  add_group 'Libraries',   'lib'
end

# set minimum coverage percentage
SimpleCov.minimum_coverage ENV['MIN_CODE_COVERAGE_SCORE'].to_f || 90
