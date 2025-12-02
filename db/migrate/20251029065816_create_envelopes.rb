class CreateEnvelopes < ActiveRecord::Migration[6.1]
  def change
    create_table :envelopes, id: :uuid do |t|
      t.string "filename"
      t.boolean "aatl_cert"
      t.boolean "ltv_cert"
      t.boolean "is_certified", default: false
      t.timestamps
    end
  end
end
