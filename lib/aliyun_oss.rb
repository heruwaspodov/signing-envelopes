# frozen_string_literal: true

require 'aliyun/oss'

class AliyunOss
  # make the class statically available
  class << self
    def upload(object_key, file)
      new.upload(object_key, file)
    end

    def get(object_key, tempfile)
      new.get(object_key, tempfile)
    end

    def copy(object_key, target_key)
      new.copy(object_key, target_key)
    end

    def exist?(object_key)
      new.exist?(object_key)
    end

    def list_objects(options = {})
      new.list_objects(options)
    end

    def delete(object_key)
      new.delete(object_key)
    end
  end

  # upload file to aliyun oss
  # @param object_key [String] the object key
  # @param file [File] the file
  #
  # @return [Aliyun::OSS::Object]
  def upload(object_key, file)
    file = file.path if file.is_a?(File) || file.is_a?(Tempfile)

    bucket.put_object(object_key, file: file)
  end

  def get(object_key, tempfile)
    bucket.get_object(object_key, file: tempfile)
  rescue Aliyun::OSS::ServerError => e
    handle_server_error(e, "Key: #{object_key}")
  end

  def copy(object_key, target_key)
    bucket.copy_object(object_key, target_key)
  rescue Aliyun::OSS::ServerError => e
    handle_server_error(e, "Source Key: #{object_key}, Target Key: #{target_key}")
  end

  def exist?(object_key)
    bucket.object_exist?(object_key)
  rescue Aliyun::OSS::ServerError => e
    handle_server_error(e, "Key: #{object_key}", :info)
  end

  def list_objects(options = {})
    bucket.list_objects(options)
  end

  def delete(object_key)
    bucket.delete_object(object_key)
  rescue Aliyun::OSS::ServerError => e
    handle_server_error(e, "Key: #{object_key}")
  end

  def bucket
    client.get_bucket(ENV['ALICLOUD_OSS_BUCKET'])
  end

  private

    def handle_server_error(error, context_info, log_level = :error)
      enhanced_message = "#{error.message} (#{context_info})"
      Rails.logger.send(log_level, "[AliyunOss] #{enhanced_message}")
      raise error.class, enhanced_message, error.backtrace
    end

    def client
      @client ||= Aliyun::OSS::Client.new(
        endpoint: aliyun_oss_endpoint,
        access_key_id: ENV['ALICLOUD_OSS_ACCESS_KEY_ID'],
        access_key_secret: ENV['ALICLOUD_OSS_ACCESS_KEY_SECRET']
      )
    end

    def aliyun_oss_endpoint
      ENV['ALIYUN_OSS_ENDPOINT'] || 'oss-ap-southeast-5.aliyuncs.com'
    end
end
