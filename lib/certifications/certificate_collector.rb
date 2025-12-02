# frozen_string_literal: false

module Certifications
  # Helper class to extract certificates from a signature
  class CertificateCollector
    include Helper

    attr_reader :root_cert_url, :tsa_cert_url

    def initialize(signature)
      @pkcs7 = OpenSSL::PKCS7.new signature.contents
      @root_cert_url = ENV['CERT_URL_ROOT'] || 'https://secure.globalsign.net/cacert/root-r6.crt'
      @tsa_cert_url = ENV['CERT_URL_TSA'] || 'https://secure.globalsign.com/cacert/gstsasha2g4.crt'
      @collections = nil
    end

    def root_cert
      @root_cert ||= x509_certificate(@root_cert_url)
    end

    def tsa_cert
      @tsa_cert ||= x509_certificate(@tsa_cert_url)
    end

    def tsa_issuer_cert
      @tsa_issuer_cert ||= issuer_cert(tsa_cert, root_cert)
    end

    # TSA certificate chain used for timestamp
    def tsa_cert_chain
      return [] if tsa_cert.nil?

      [tsa_cert, tsa_issuer_cert]
    end

    # the certificate chain used to sign
    def certificate_chain
      collections.map { |_k, v| v[:cert] }
    end

    # OCSPs certificate chain to validate (subject & issuer )
    def subject_issuer_chain
      collections.filter_map do |_k, v|
        next if v[:issuer_id].nil?

        [v[:cert], @collections[v[:issuer_id]][:cert]]
      end
    end

    def collections
      return @collections unless @collections.nil?

      @collections = {}
      @pkcs7.certificates.each do |cert|
        traverse(cert)
      end

      @collections
    end

    # traverse and get certificates recursively up to the root certificate
    # rubocop:disable Metrics/AbcSize
    def traverse(cert)
      return if cert.nil?

      id = cert.serial.to_i

      return if @collections.key?(id)

      issuer_uri = ca_issuer_uri(cert)

      if issuer_uri.empty?
        root_id = root_cert ? root_cert.serial.to_i : nil

        # root cert - end of certificate chain
        add_to_collections(id, cert, root_id)
        add_to_collections(root_id, root_cert, nil)

        return
      end

      issuer_crt = x509_certificate(issuer_uri)

      issuer_id = issuer_crt ? issuer_crt.serial.to_i : nil
      add_to_collections(id, cert, issuer_id)

      traverse(issuer_crt)
    end
    # rubocop:enable Metrics/AbcSize

    def add_to_collections(id, cert, issuer_id)
      return if cert.nil? || @collections.key?(id)

      @collections[id] = {
        cert: cert,
        issuer_id: issuer_id
      }
    end
  end
end
