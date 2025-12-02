# frozen_string_literal: true

# This seed ensures there are always exactly 2 envelopes:
# 1 with is_certified = true and 1 with is_certified = false
# Each envelope will have 1 associated recipient

puts 'Seeding envelopes and recipients...'

# Delete existing envelopes and their recipients to maintain consistency
puts 'Cleaning up existing envelope data...'
EnvelopeRecipient.delete_all
Envelope.delete_all

# Create envelope with is_certified = true
certified_envelope = Envelope.create!(
  filename: 'Certified Document.pdf',
  is_certified: true
)

# Create envelope with is_certified = false
non_certified_envelope = Envelope.create!(
  filename: 'Non-Certified Document.pdf',
  is_certified: false
)

# Create recipients for each envelope with annotations
# rubocop:disable Layout/LineLength
EnvelopeRecipient.create!(
  email: 'certified@example.com',
  envelope: certified_envelope,
  annotations: [
    { 'page' => 1, 'position_x' => 50, 'position_y' => 461, 'canvas_width' => 852, 'canvas_height' => 1204.25,
      'element_width' => 198, 'element_height' => 106, 'type_of' => 'signature', 'all_pages' => false, 'value' => '', 'font_size' => 12, 'date_format' => 0, 'sequence' => 2, 'linked_sequence' => nil, 'id' => 'D7pQzP7WeX', 'values' => [{ 'type_of' => 'signature', 'position_x' => 0, 'position_y' => 0, 'canvas_width' => 0, 'canvas_height' => 0, 'element_width' => 180, 'element_height' => 80, 'font_size' => 12, 'icon_size' => 0 }], 'is_lock_content' => false },
    { 'page' => 1, 'position_x' => 50, 'position_y' => 580, 'canvas_width' => 852, 'canvas_height' => 1204.25,
      'element_width' => 198, 'element_height' => 106, 'type_of' => 'signature', 'all_pages' => false, 'value' => '', 'font_size' => 12, 'date_format' => 0, 'sequence' => 3, 'linked_sequence' => nil, 'id' => 'J0KvAqygmU', 'values' => [{ 'type_of' => 'signature', 'position_x' => 0, 'position_y' => 0, 'canvas_width' => 0, 'canvas_height' => 0, 'element_width' => 180, 'element_height' => 80, 'font_size' => 12, 'icon_size' => 0 }], 'is_lock_content' => false },
    { 'page' => 1, 'position_x' => 50, 'position_y' => 706, 'canvas_width' => 852, 'canvas_height' => 1204.25,
      'element_width' => 198, 'element_height' => 106, 'type_of' => 'signature', 'all_pages' => false, 'value' => '', 'font_size' => 12, 'date_format' => 0, 'sequence' => 4, 'linked_sequence' => nil, 'id' => 'pEYW7za2mn', 'values' => [{ 'type_of' => 'signature', 'position_x' => 0, 'position_y' => 0, 'canvas_width' => 0, 'canvas_height' => 0, 'element_width' => 180, 'element_height' => 80, 'font_size' => 12, 'icon_size' => 0 }], 'is_lock_content' => false },
    { 'page' => 1, 'position_x' => 50, 'position_y' => 830, 'canvas_width' => 852, 'canvas_height' => 1204.25,
      'element_width' => 198, 'element_height' => 106, 'type_of' => 'signature', 'all_pages' => false, 'value' => '', 'font_size' => 12, 'date_format' => 0, 'sequence' => 5, 'linked_sequence' => nil, 'id' => '2duO7uXb9Q', 'values' => [{ 'type_of' => 'signature', 'position_x' => 0, 'position_y' => 0, 'canvas_width' => 0, 'canvas_height' => 0, 'element_width' => 180, 'element_height' => 80, 'font_size' => 12, 'icon_size' => 0 }], 'is_lock_content' => false },
    { 'page' => 1, 'position_x' => 50, 'position_y' => 953, 'canvas_width' => 852, 'canvas_height' => 1204.25,
      'element_width' => 198, 'element_height' => 106, 'type_of' => 'signature', 'all_pages' => false, 'value' => '', 'font_size' => 12, 'date_format' => 0, 'sequence' => 6, 'linked_sequence' => nil, 'id' => 'VMoI6ykMXX', 'values' => [{ 'type_of' => 'signature', 'position_x' => 0, 'position_y' => 0, 'canvas_width' => 0, 'canvas_height' => 0, 'element_width' => 180, 'element_height' => 80, 'font_size' => 12, 'icon_size' => 0 }], 'is_lock_content' => false },
    { 'page' => 1, 'position_x' => 50, 'position_y' => 1078, 'canvas_width' => 852, 'canvas_height' => 1204.25,
      'element_width' => 198, 'element_height' => 106, 'type_of' => 'signature', 'all_pages' => false, 'value' => '', 'font_size' => 12, 'date_format' => 0, 'sequence' => 7, 'linked_sequence' => nil, 'id' => 'fE3E0eu18r', 'values' => [{ 'type_of' => 'signature', 'position_x' => 0, 'position_y' => 0, 'canvas_width' => 0, 'canvas_height' => 0, 'element_width' => 180, 'element_height' => 80, 'font_size' => 12, 'icon_size' => 0 }], 'is_lock_content' => false },
    { 'page' => 1, 'position_x' => 300, 'position_y' => 956, 'canvas_width' => 852, 'canvas_height' => 1204.25,
      'element_width' => 198, 'element_height' => 106, 'type_of' => 'signature', 'all_pages' => false, 'value' => '', 'font_size' => 12, 'date_format' => 0, 'sequence' => 8, 'linked_sequence' => nil, 'id' => '5-T-M2wG0d', 'values' => [{ 'type_of' => 'signature', 'position_x' => 0, 'position_y' => 0, 'canvas_width' => 0, 'canvas_height' => 0, 'element_width' => 180, 'element_height' => 80, 'font_size' => 12, 'icon_size' => 0 }], 'is_lock_content' => false },
    { 'page' => 1, 'position_x' => 300, 'position_y' => 829, 'canvas_width' => 852, 'canvas_height' => 1204.25,
      'element_width' => 198, 'element_height' => 106, 'type_of' => 'signature', 'all_pages' => false, 'value' => '', 'font_size' => 12, 'date_format' => 0, 'sequence' => 9, 'linked_sequence' => nil, 'id' => 'S5LgzNACzr', 'values' => [{ 'type_of' => 'signature', 'position_x' => 0, 'position_y' => 0, 'canvas_width' => 0, 'canvas_height' => 0, 'element_width' => 180, 'element_height' => 80, 'font_size' => 12, 'icon_size' => 0 }], 'is_lock_content' => false },
    { 'page' => 1, 'position_x' => 300, 'position_y' => 704, 'canvas_width' => 852, 'canvas_height' => 1204.25,
      'element_width' => 198, 'element_height' => 106, 'type_of' => 'signature', 'all_pages' => false, 'value' => '', 'font_size' => 12, 'date_format' => 0, 'sequence' => 10, 'linked_sequence' => nil, 'id' => 'VKaGEY0sIq', 'values' => [{ 'type_of' => 'signature', 'position_x' => 0, 'position_y' => 0, 'canvas_width' => 0, 'canvas_height' => 0, 'element_width' => 180, 'element_height' => 80, 'font_size' => 12, 'icon_size' => 0 }], 'is_lock_content' => false },
    { 'page' => 1, 'position_x' => 300, 'position_y' => 576, 'canvas_width' => 852, 'canvas_height' => 1204.25,
      'element_width' => 198, 'element_height' => 106, 'type_of' => 'signature', 'all_pages' => false, 'value' => '', 'font_size' => 12, 'date_format' => 0, 'sequence' => 11, 'linked_sequence' => nil, 'id' => 'XbemKmM28M', 'values' => [{ 'type_of' => 'signature', 'position_x' => 0, 'position_y' => 0, 'canvas_width' => 0, 'canvas_height' => 0, 'element_width' => 180, 'element_height' => 80, 'font_size' => 12, 'icon_size' => 0 }], 'is_lock_content' => false }
  ]
)

EnvelopeRecipient.create!(
  email: 'noncertified@example.com',
  envelope: non_certified_envelope,
  annotations: [
    { 'page' => 1, 'position_x' => 648, 'position_y' => 23, 'canvas_width' => 852, 'canvas_height' => 1102.5859375, 'element_width' => 180, 'element_height' => 80, 'type_of' => 'signature', 'all_pages' => false, 'value' => '', 'font_size' => 12, 'date_format' => 0, 'sequence' => 1, 'linked_sequence' => nil, 'is_lock_content' => false }
  ]
)
# rubocop:enable Layout/LineLength

puts "Created certified envelope: ID #{certified_envelope.id}"
puts "Created non-certified envelope: ID #{non_certified_envelope.id}"
puts 'Seeding completed!'
