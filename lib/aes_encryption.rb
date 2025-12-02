# frozen_string_literal: true

module AesEncryption
  class << self
    def encrypt(plain_text)
      cipher = OpenSSL::Cipher.new('aes-128-cbc')
      cipher.encrypt
      cipher.key = ENV['AES_KEY'] || 'FIBQGOAIMBNRLALL'
      cipher.iv = ENV['AES_IV'] || 'XFBFQQSANJVHLPCU'
      cipher_text = cipher.update(plain_text) + cipher.final
      Base64.strict_encode64(cipher_text)
    rescue StandardError
      ''
    end

    def encrypt_safe(plain_text)
      Base64.urlsafe_encode64(encrypt(plain_text))
    end

    def decrypt(cipher_text)
      cipher = OpenSSL::Cipher.new('aes-128-cbc')
      cipher.decrypt
      cipher.key = ENV['AES_KEY'] || 'FIBQGOAIMBNRLALL'
      cipher.iv = ENV['AES_IV'] || 'XFBFQQSANJVHLPCU'
      cipher.update(Base64.strict_decode64(cipher_text)) + cipher.final
    rescue StandardError
      ''
    end

    def decrypt_safe(cipher_text)
      cipher_text = Base64.urlsafe_decode64(cipher_text)
      decrypt(cipher_text)
    end
  end
end
