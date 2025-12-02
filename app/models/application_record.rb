# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class        = true
  self.implicit_order_column = :created_at

  connects_to database: {
    writing: :primary,
    reading: :primary_replica
  }

  AUDIT_PARAMS = Struct.new(:associated, :action, :comment, :changes)

  def esign_audit(resource, audit_params)
    return unless resource.include?(Audited::Auditor::AuditedInstanceMethods)

    audits.create!(
      associated: audit_params.associated,
      action: audit_params.action,
      comment: audit_params.comment,
      audited_changes: audit_params.changes
    )
  end
end
