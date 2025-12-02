# frozen_string_literal: true

HealthBit.configure do |c|
  c.success_text = '1.0.0'
  c.headers = {
    'Content-Type' => 'text/plain;charset=utf-8',
    'Cache-Control' => 'private,max-age=0,must-revalidate,no-store'
  }
  c.success_code = 200
  c.fail_code = 500
  c.show_backtrace = false
end

HealthCheck = HealthBit.clone

HealthCheck.add('Database') do |_env|
  ApplicationRecord.connection.select_value('SELECT 1') == 1
end

HealthCheck.add('Redis') do |_env|
  Redis.current.ping == 'PONG'
end

HealthCheck.add('Sidekiq') do |_env|
  Sidekiq.redis(&:ping) == 'PONG'
end

# temp disable S3 check during alicloud migration
# HealthCheck.add('S3') do |_env|
#   s3_object = Amazons::S3CheckObject.new('health_check.txt')
#   s3_object.exists?
# end
