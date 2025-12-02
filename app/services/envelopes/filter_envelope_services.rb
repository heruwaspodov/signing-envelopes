# frozen_string_literal: true

module Envelopes
  # rubocop:disable Metrics/ModuleLength
  module FilterEnvelopeServices
    def query_status
      define_params_status if @status.present?
      define_params_signing_status
      define_params_approval_status

      @envelopes = @envelopes.select_for_dashboard.where(status: @status) if @status.present?

      query_signing_status_or_approval_status
      query_signing_status if @signing_status.present? && @approval_status.blank?
      query_approval_status if @approval_status.present? && @signing_status.blank?

      @envelopes = @envelopes.select_for_dashboard
    end

    def define_params_status
      @status = @status.to_s.split(',')
      @status &= Envelope::OPTIONS_STATUS
    end

    def define_params_signing_status
      return unless @signing_status.present?

      @signing_status = @signing_status.to_s.split(',')
      @signing_status &= Envelope::OPTIONS_SIGNING_STATUS
    end

    def define_params_approval_status
      return unless @approval_status.present?

      @approval_status = @approval_status.split(',')
      @approval_status &= Envelope::OPTIONS_APPROVAL_STATUS
    end

    def query_subject
      return unless @subject.present?

      # adjust so that _ and % does not count as special pattern
      @subject = @subject.gsub('_', '\_').gsub('%', '\%')
      filter_by_name = @envelopes.where.not(name: nil).where('envelopes.name ILIKE ?',
                                                             "%#{@subject}%").select_for_dashboard
      filter_by_filename = @envelopes.where(name: nil).where('envelopes.filename ILIKE ?',
                                                             "%#{@subject}%").select_for_dashboard

      @envelopes = filter_by_name.union(filter_by_filename).select_for_dashboard
    end

    def query_by_search
      return unless @search.present?

      is_uuid = @search =~ REGEXP::UUID ? @search : nil

      @envelopes = @envelopes.where(
        "(#{'envelopes.id = :exact_id OR' if is_uuid}
        (envelopes.name IS NOT NULL AND envelopes.name ILIKE :q) OR
        (envelopes.name IS NULL AND envelopes.filename ILIKE :q))",
        q: "%#{@search}%",
        exact_id: @search
      ).select_for_dashboard
    end

    def query_envelope_folder
      envelope_ids = @envelopes.left_joins(:folders)
                               .where(folders: { envelope_folders: { folder_id: @folder_id } })
                               .pluck('envelopes.id') + (@envelope_group_ids || [])

      @envelopes.where(id: envelope_ids).select_for_dashboard
    end

    def query_folder
      return unless @folder_id.present?

      @folder_id = @folder_id.to_s.split(',')

      @envelopes = query_envelope_folder
    end

    def query_id
      return unless @id.present?

      @envelopes = @envelopes.where(id: @id).select_for_dashboard
    end

    def query_company_id
      return unless @company_id.present?

      @envelopes = @envelopes.where(company_id: @company_id).select_for_dashboard
    end

    def query_workspace_id
      return unless @workspace_id.present?

      @workspace_id = @workspace_id.to_s.split(',')

      @envelopes = @envelopes.where(workspace_id: @workspace_id).select_for_dashboard
    end

    def query_sender
      return unless @sender_id.present?

      @sender_id = @sender_id.to_s.split(',')

      @envelopes = @envelopes.where('created_by = ? OR owned_by = ?', @sender_id,
                                    @sender_id).select_for_dashboard
    end

    def query_created_by
      return unless @created_by.present?

      users = User.where(id: @envelopes.map { |e| e.owned_by || e.created_by }.uniq)
      return unless users.present?

      filtered_user_ids = users.where('full_name ILIKE (:search)',
                                      { search: "%#{@created_by}%" })
                               .pluck(:id)

      @envelopes = @envelopes.where('created_by IN (?) OR owned_by IN (?)',
                                    filtered_user_ids,
                                    filtered_user_ids).select_for_dashboard
    end

    def query_signer
      return unless @signer.present?

      status = @signing_status.reject { |s| s == 'need_to_sign' } if @signing_status.present?
      @envelopes = if status.present? || @signing_status.nil?
                     @envelopes.signer(@signer).select_for_dashboard
                   else
                     @envelopes.where('recipients.name ILIKE ?',
                                      "%#{@signer}%").select_for_dashboard
                   end
    end

    def query_in_progress_workspace
      need_to_sign = query_need_to_sign_pov_user_id.or(query_need_to_sign_pov_email)

      @envelopes = if need_to_sign.present?
                     @envelopes.where(signing_status: @signing_status)
                               .where.not(
                                 id: need_to_sign.pluck('envelopes.id')
                               ).select_for_dashboard
                   else
                     @envelopes.where(signing_status: @signing_status).select_for_dashboard
                   end

      @envelopes.select_for_dashboard
    end

    def query_type_of
      return unless @type_of.present?

      if @type_of == 'bulk_upload'
        @envelopes = @envelopes.where.not(envelope_group_id: nil).select_for_dashboard
        return
      end

      @envelopes = @envelopes.where(envelope_group_id: nil).select_for_dashboard
    end

    def query_group
      return unless @group_id.present?

      @envelopes = @envelopes.where(envelope_group_id: @group_id).select_for_dashboard
    end

    def query_signing_status_or_approval_status
      return unless @signing_status.present? && @approval_status.present?

      query_approval_status = @envelopes.where(approval_status: @approval_status)
      query_signing_status = if @signing_status.include? 'need_to_sign'
                               query_need_to_sign_pov
                             elsif @signing_status.include? 'in_progress'
                               query_in_progress_workspace
                             else
                               @envelopes.where(signing_status: @signing_status)
                             end

      @envelopes = query_signing_status.select_for_dashboard.union(
        query_approval_status.select_for_dashboard
      )
      @envelopes = @envelopes.select_for_dashboard
    end

    def query_envelope_type_category_id
      return unless @envelope_type_category_id.present?

      @envelope_type_category_ids = @envelope_type_category_id.to_s.split(',')

      @envelopes = @envelopes.joins(:envelope_type)
                             .where(envelope_types: {
                                      envelope_type_category_id: @envelope_type_category_ids
                                    }).select_for_dashboard
    end

    def query_compliance
      return unless @compliance.present?

      comply_psre = @compliance == 'psre'

      @envelopes = @envelopes.where(comply_psre: comply_psre).select_for_dashboard
    end

    def query_envelope_type_id
      return unless @envelope_type_id.present?

      @envelope_type_ids = @envelope_type_id.to_s.split(',')

      @envelopes = @envelopes.where(envelope_type_id: @envelope_type_ids).select_for_dashboard
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
