# frozen_string_literal: true

# solving a problem on sandbox that cannot read the file configuration on YML such treat as fallback
CLOUD_HSM_CONFIG = {
  cloud_provider: ENV['CLOUDHSM_PROVIDER'] || 'aws',
  region: ENV['CLOUDHSM_REGION'] || 'ap-southeast-5',
  region_cluster: ENV['CLOUDHSM_CLUSTER_REGION'] || 'ap-southeast-5',

  aws: {
    hsm: {
      engine: ENV['CLOUDHSM_AWS_HSM_INTEGRATION_TYPE'] || 'cloudhsm',
      dir: ENV['CLOUDHSM_AWS_DIR'] || '/opt/cloudhsm/etc',
      dir_cluster: ENV['CLOUDHSM_AWS_CLUSTER_DIR'] || '/opt/cloudhsm/etc',
      ca: ENV['CLOUDHSM_AWS_CUSTOMERCA_DIR'] || '/opt/cloudhsm/etc/customerCA.crt',
      private_key: ENV['CLOUDHSM_AWS_PRIVATEKEY_DIR'] || '/opt/cloudhsm/etc/app-private-key.pem',
      cert: ENV['CLOUDHSM_AWS_GLOBALSIGN_CERT'] || '/opt/cloudhsm/etc/globalsign-cert.crt',
      intermediate1: ENV['CLOUDHSM_AWS_GLOBALSIGN_INTERMEDIATE_1'] || '/opt/cloudhsm/etc/globalsign-intermediate1.crt',
      intermediate2: ENV['CLOUDHSM_AWS_GLOBALSIGN_INTERMEDIATE_2'] || '/opt/cloudhsm/etc/globalsign-intermediate2.crt'
    }
  },

  aliyun: {
    hsm: {
      engine: ENV['CLOUDHSM_ALI_HSM_INTEGRATION_TYPE'] || 'hsm_openssl',
      dir: ENV['CLOUDHSM_ALI_DIR'] || '/opt/hsm/etc',
      dir_cluster: ENV['CLOUDHSM_ALI_CLUSTER_DIR'] || '/opt/hsm/etc',
      ca: ENV['CLOUDHSM_ALI_CUSTOMERCA_DIR'] || '/opt/hsm/etc/customerCA.crt',
      private_key: ENV['CLOUDHSM_ALI_PRIVATEKEY_DIR'] || '/opt/hsm/etc/app-private-key.pem',
      cert: ENV['CLOUDHSM_ALI_GLOBALSIGN_CERT'] || '/opt/hsm/etc/globalsign-cert.crt',
      intermediate1: ENV['CLOUDHSM_ALI_GLOBALSIGN_INTERMEDIATE_1'] || '/opt/hsm/etc/globalsign-intermediate1.crt',
      intermediate2: ENV['CLOUDHSM_ALI_GLOBALSIGN_INTERMEDIATE_2'] || '/opt/hsm/etc/globalsign-intermediate2.crt'
    }
  }
}.freeze

CLOUD_HSM_PROVIDER = begin
  Rails.application.config_for(:cloud_hsm_provider) || CLOUD_HSM_CONFIG
rescue StandardError
  CLOUD_HSM_CONFIG
end

CLOUD_HSM_STRUCT = Struct.new(:current_provider, :current_config)
CLOUD_HSM_CERT_CONFIG_STRUCT = Struct.new(:engine, :dir, :dir_cluster, :ca, :private_key, :cert, :intermediate1,
                                          :intermediate2)

Rails.application.configure do
  current_provider = CLOUD_HSM_PROVIDER[:cloud_provider].to_sym

  aws_config = CLOUD_HSM_CERT_CONFIG_STRUCT.new(
    CLOUD_HSM_PROVIDER.dig(:aws, :hsm, :engine),
    CLOUD_HSM_PROVIDER.dig(:aws, :hsm, :dir),
    CLOUD_HSM_PROVIDER.dig(:aws, :hsm, :dir_cluster),
    CLOUD_HSM_PROVIDER.dig(:aws, :hsm, :ca),
    CLOUD_HSM_PROVIDER.dig(:aws, :hsm, :private_key),
    CLOUD_HSM_PROVIDER.dig(:aws, :hsm, :cert),
    CLOUD_HSM_PROVIDER.dig(:aws, :hsm, :intermediate1),
    CLOUD_HSM_PROVIDER.dig(:aws, :hsm, :intermediate2)
  )

  aliyun_config = CLOUD_HSM_CERT_CONFIG_STRUCT.new(
    CLOUD_HSM_PROVIDER.dig(:aliyun, :hsm, :engine),
    CLOUD_HSM_PROVIDER.dig(:aliyun, :hsm, :dir),
    CLOUD_HSM_PROVIDER.dig(:aliyun, :hsm, :dir_cluster),
    CLOUD_HSM_PROVIDER.dig(:aliyun, :hsm, :ca),
    CLOUD_HSM_PROVIDER.dig(:aliyun, :hsm, :private_key),
    CLOUD_HSM_PROVIDER.dig(:aliyun, :hsm, :cert),
    CLOUD_HSM_PROVIDER.dig(:aliyun, :hsm, :intermediate1),
    CLOUD_HSM_PROVIDER.dig(:aliyun, :hsm, :intermediate2)
  )

  config.cloud_hsm = CLOUD_HSM_STRUCT.new(
    current_provider,
    CLOUD_HSM_PROVIDER[:cloud_provider] == 'aws' ? aws_config : aliyun_config
  )
end
