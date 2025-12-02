# frozen_string_literal: true

# This module holds static configuration values for the application,
# replacing the database-backed Config model for better performance and
# easier management of non-dynamic values.
module AppConfig
  # Corresponds to Config::KEY_CERT_LOCATION
  def self.cert_location
    'Indonesia'
  end

  # Corresponds to Config::KEY_CERT_CONTACT
  def self.cert_contact
    'mekari-esign@mekari.com'
  end

  # Corresponds to Config.cert_signature_size
  def self.cert_signature_size
    # Increased to accommodate PAdES signatures with timestamp and certificate chain
    # PAdES-B-LTA signatures require more space for the signature container
    100_000
  end

  # Corresponds to Config::KEY_TSA_URL
  def self.tsa_url
    ENV['TSA_SERVER_URL'] || 'http://aatl-timestamp.globalsign.com/tsa/v4v5effk07zor410rew22z'
  end

  # Corresponds to Config::KEY_CERT_REASON
  def self.cert_reason
    'Mekari Sign'
  end
end
