# frozen_string_literal: false

module Certifications
  class DocumentSecurityStore
    include Helper

    attr_reader :sig_cert_chain, :tsa_cert_chain, :ocsps_cert_chain, :certs_list, :envelope_id

    def initialize(envelope_id)
      @envelope_id = envelope_id
    end

    # rubocop:disable Metrics/AbcSize

    # Add LTV (Long-Term Valication) to a signed PDF document
    #
    # @param string filename path to signed document
    def add_ltv(filename)
      @signed_doc = HexaPDF::Document.open(filename)

      return if @signed_doc.blank?

      signature = @signed_doc.signatures.to_a.last

      # We only add LTV for latest mekari signature
      return if signature.nil?
      return unless ['mekari', 'pt mid solusi nusantara'].include?(signature.signer_name.downcase)

      build_cert_chain(signature)

      log "Adding LTV to #{filename}"
      create_dss_catalog
      add_certs_data
      sig_key = create_vri_signature_key(signature)
      return unless add_validation(sig_key)

      # Write the result
      log 'DSS catalog is written to the file'
      @signed_doc.write(filename, validate: false, incremental: true)

      true
    end

    def build_cert_chain(signature)
      cert_collector = CertificateCollector.new(signature)

      @sig_cert_chain = cert_collector.certificate_chain
      @tsa_cert_chain = cert_collector.tsa_cert_chain

      @certs_list = merge_chain(@sig_cert_chain, @tsa_cert_chain)
      @ocsps_cert_chain = cert_collector.subject_issuer_chain + [@tsa_cert_chain]

      true
    end

    def add_validation(sig_key)
      # 1st attempt. Trying to request and add OCSP validation
      ocsp_vlidation_ref = add_ocsps_data(sig_key)

      return true if ocsp_vlidation_ref.present?

      log 'Fallback to CRL. No valid OCSP response'

      # 2nd attempt. Trying to request and add CRL validation
      crl_vlidation_ref = add_crls_data(sig_key)

      return true if crl_vlidation_ref.present?

      log 'No succesful validation. LTV not yet enabled'

      false
    end

    # Create DSS catalog structure as indirect references
    def create_dss_catalog
      @signed_doc.catalog[:DSS] = @signed_doc.add({})
      @signed_doc.catalog[:DSS][:CRLs] = @signed_doc.add([])
      @signed_doc.catalog[:DSS][:Certs] = @signed_doc.add([])
      @signed_doc.catalog[:DSS][:OCSPs] = @signed_doc.add([])
      @signed_doc.catalog[:DSS][:VRI] = @signed_doc.add({})
    end

    def create_vri_signature_key(signature)
      # The VRI dictionary key is the base-16-encoded SHA-1
      #   of a signature in uppercase (ISO 32000-2:2020)
      sig_key = OpenSSL::Digest.new('SHA1').hexdigest(signature[:Contents]).upcase
      @signed_doc.catalog[:DSS][:VRI][sig_key.to_sym] = @signed_doc.add({})

      sig_key
    end

    def add_certs_data
      certs_list.each do |cert_file|
        next if cert_file.nil?

        data = cert_file.to_der
        cert_ref = @signed_doc.add({ Filter: [:FlateDecode], Length: data.size }, stream: data)
        @signed_doc.catalog[:DSS][:Certs].insert(@signed_doc.catalog[:DSS][:Certs].length, cert_ref)
      end
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    def add_ocsps_data(sig_key)
      # TODO: remove this toggle after passing the staging test
      return if Flipper.enabled?(:ft_add_ltv_use_crl)

      ocsp_vlidation_ref = nil

      ocsps_cert_chain.each do |chain|
        next if chain.first.nil?

        certificate_id = OpenSSL::OCSP::CertificateId.new(chain.first, chain.second,
                                                          OpenSSL::Digest.new('SHA1'))
        (chain.first.ocsp_uris || []).each do |ocsp_str|
          ocsf_ref = add_ocsp(certificate_id, ocsp_str)
          ocsp_vlidation_ref ||= ocsf_ref
        end
      end

      # We can include all validation results but it turns out that Adobe marks it as LTV-enabled
      # even though it only uses the first validation
      if ocsp_vlidation_ref.present?
        log 'LTV enabled using OCSP validation'
        add_vri_reference(sig_key, 'OCSP', ocsp_vlidation_ref)
      end

      ocsp_vlidation_ref
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    def add_ocsp(certificate_id, ocsp_str)
      log "Request OCSP to #{ocsp_str}"

      ocsp = get_ocsp_response(certificate_id, URI(ocsp_str))

      return if ocsp.blank? || ocsp.status_string != 'successful'

      log ' > OCSP response OK'

      data = ocsp.to_der
      ocsp_ref = @signed_doc.add({ Filter: [:FlateDecode], Length: data.size }, stream: data)
      @signed_doc.catalog[:DSS][:OCSPs].insert(@signed_doc.catalog[:DSS][:OCSPs].length, ocsp_ref)

      ocsp_ref
    end

    def get_ocsp_response(certificate_id, ocsp_uri)
      ocsp_request = OpenSSL::OCSP::Request.new
      ocsp_request.add_certid certificate_id
      ocsp_request.add_nonce

      http_response = post_ocsp_uri(certificate_id, ocsp_request, ocsp_uri)

      unless http_response.is_a?(Net::HTTPOK)
        main_msg = "Invalid response from OCSP Server: #{ocsp_uri}"
        Alert::NotifyErrorAlertJob.perform_later "#{main_msg}" \
                                                 "\nwhen processing envelope id: #{@envelope_id}" \
                                                 "\ngot response:#{http_response.inspect}" \

        return
      end

      OpenSSL::OCSP::Response.new(http_response.body)
    end

    def add_crls_data(sig_key)
      crls_to_validate = [sig_cert_chain.first, tsa_cert_chain.first]
      crl_vlidation_ref = nil

      crls_to_validate.each do |cert_file|
        (cert_file&.crl_uris || []).each do |crl_uri|
          crl_ref = add_crl(crl_uri)
          crl_vlidation_ref ||= crl_ref
        end
      end

      if crl_vlidation_ref.present?
        log 'LTV enabled using CRL validation'
        add_vri_reference(sig_key, 'CRL', crl_vlidation_ref)
      end

      crl_vlidation_ref
    end

    def add_crl(crl_uri)
      log "Request CRL to #{crl_uri}"

      crl = get_crl_response(crl_uri)

      return if crl.blank?

      log ' > CRL response OK'

      data = crl.to_der
      crl_ref = @signed_doc.add({ Filter: [:FlateDecode], Length: data.size }, stream: data)
      @signed_doc.catalog[:DSS][:CRLs].insert(@signed_doc.catalog[:DSS][:CRLs].length, crl_ref)
      crl_ref
    end

    def get_crl_response(crl_uri)
      crl_tempfile = read_uri_crl(crl_uri)

      return if crl_tempfile.nil? || crl_tempfile.empty?

      OpenSSL::X509::CRL.new(crl_tempfile)
    end

    # rubocop:enable Metrics/AbcSize

    def add_vri_reference(sig_key, type, reference)
      @signed_doc.catalog[:DSS][:VRI][sig_key.to_sym][type.to_sym] = @signed_doc.add([])
      @signed_doc.catalog[:DSS][:VRI][sig_key.to_sym][type.to_sym].insert(0, reference)
    end

    private

      def read_uri_crl(crl_uri)
        uri = URI.parse(crl_uri)
        cache_key = "CRL/#{url_to_underscore(uri)}"
        if Flipper.enabled? :ft_cache_certificate
          Rails.cache.fetch(cache_key, skip_nil: true, expired_in: 6.hours) do
            uri.open.read
          end
        else
          uri.open.read
        end
      rescue OpenURI::HTTPError => e
        main_msg = "Invalid response from CRL Server: #{crl_uri}"
        Alert::NotifyErrorAlertJob.perform_later "#{main_msg}" \
                                                 "\nwhen processing envelope id: #{@envelope_id}" \
                                                 "\ngot response:#{e.inspect}"
        raise e
      end

      def post_ocsp_uri(certificate_id, ocsp_request, ocsp_uri)
        cache_key = "OCSP/#{certificate_id&.serial}/#{url_to_underscore(ocsp_uri)}"
        # http only
        if Flipper.enabled? :ft_cache_certificate
          Rails.cache.fetch(cache_key, skip_nil: true, expires_in: 6.hours) do
            Net::HTTP.post(ocsp_uri, ocsp_request.to_der,
                           'content-type' => 'application/ocsp-request')
          end
        else
          Net::HTTP.post(ocsp_uri, ocsp_request.to_der,
                         'content-type' => 'application/ocsp-request')
        end
      end
  end
end
