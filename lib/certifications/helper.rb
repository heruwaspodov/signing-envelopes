# frozen_string_literal: false

module Certifications
  module Helper
    # merge chain of OpenSSL::X509::Certificate
    def merge_chain(source, addition)
      addition.each do |add|
        next if add.nil?

        id = add.serial.to_i

        source << add unless source.find { |cert| cert && cert.serial.to_i == id }
      end
      source
    end

    def url_to_underscore(uri)
      host = uri.host.gsub('.', '_')
      path = uri.path.gsub('/', '_')
      "#{uri.scheme}_#{host}#{path}"
    end

    def x509_certificate(crt_uri)
      log "Load certificate from #{crt_uri}"

      uri = URI.parse(crt_uri)

      crt_tempfile = if uri.is_a?(URI::HTTP)
                       uri_open_read(uri)
                     else
                       File.read crt_uri
                     end

      return if crt_tempfile.nil? || crt_tempfile.empty?

      crt = OpenSSL::X509::Certificate.new(crt_tempfile)

      log " > got #{crt.subject}"

      crt
    end

    # get CA issuer URI from OpenSSL::X509::Certificate param
    # we can use the openssl CLI to easily determine CA Issuer info
    #   $ openssl x509 -text -noout -in certificate.crt
    def ca_issuer_uri(cert)
      uri = ''
      ca_info = cert&.extensions&.find { |ext| ext.oid == 'authorityInfoAccess' }
      return uri if ca_info.nil?

      ca_info.value.split(/\n/).each do |n|
        if n[0, 16] == 'CA Issuers - URI'
          uri = n[17..]
          break
        end
      end

      uri
    end

    # get issuer certificate from a certificate
    def issuer_cert(cert, root_cert)
      issuer_uri = ca_issuer_uri(cert)

      if issuer_uri.empty?
        root_cert
      else
        x509_certificate(issuer_uri)
      end
    end

    def log(msg)
      Rails.logger.info "[AddLTV] envelope_id:#{@envelope_id} - #{msg}"
    end

    def uri_open_read(uri)
      if Flipper.enabled? :ft_cache_certificate
        cache_key = "CERTIFICATE/#{url_to_underscore(uri)}"
        Rails.cache.fetch(cache_key, expired_in: 6.hours) do
          uri.open.read
        end
      else
        uri.open.read
      end
    end
  end
end
