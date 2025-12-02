class CreateEnvelopeRecipients < ActiveRecord::Migration[6.1]
  def change
    create_table :envelope_recipients, id: :uuid do |t|
      t.uuid "envelope_id"
      t.string "email"
      t.jsonb "annotations", default: [], null: false
      t.datetime "signed_at"
      t.timestamps
    end
  end
end
