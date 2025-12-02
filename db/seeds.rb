# frozen_string_literal: true

# Load all seed files
Dir[File.join(Rails.root, 'db', 'seeds', '*.seeds.rb')].each do |seed_file|
  puts "Loading seed file: #{File.basename(seed_file)}"
  require seed_file
end

puts 'All seeds loaded successfully!'
