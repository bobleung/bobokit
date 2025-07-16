# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clear existing jobs to avoid duplicates
puts "Clearing existing jobs..."
Job.destroy_all

# Create sample organizations if they don't exist
puts "Creating sample organizations..."

# Sample agencies
agencies = []
3.times do
  agencies << Organisation.find_or_create_by!(name: Faker::Company.name + " Agency", type: 'Agency', active: true)
end

# Sample hospitals
clients = []
5.times do
  clients << Organisation.find_or_create_by!(name: Faker::Company.name + " Hospital", type: 'Client', active: true)
end

# Sample locums
locums = []
8.times do
  locums << Organisation.find_or_create_by!(name: "Dr. " + Faker::Name.name, type: 'Locum', active: true)
end

# Create 20 random jobs for the current month
puts "Creating 20 random jobs for the current month..."

current_month = Date.current.beginning_of_month
end_of_month = Date.current.end_of_month

20.times do |i|
  # Random date/time within current month
  start_date = Faker::Time.between(from: current_month, to: end_of_month)
  duration = [ 4, 6, 8, 10, 12 ].sample.hours
  end_date = start_date + duration

  # Random break time between 30-60 minutes
  break_minutes = rand(30..60)

  # Random pay rates (in pence)
  client_pays = rand(3000..8000) * 10  # £300-£800
  locum_gets = (client_pays * 0.7).round  # 70% of client pays
  agency_gets = client_pays - locum_gets  # 30% for agency

  job = Job.create!(
    start: start_date,
    end: end_date,
    break_minutes: break_minutes,
    actual_start: nil,
    actual_end: nil,
    actual_break_minutes: nil,
    client_pays: client_pays,
    locum_gets: locum_gets,
    agency_gets: agency_gets,
    notes_job: Faker::Lorem.paragraph(sentence_count: 2),
    notes_client: Faker::Lorem.paragraph(sentence_count: 1),
    notes_agency: Faker::Lorem.paragraph(sentence_count: 1),
    agency: agencies.sample,
    client: clients.sample,
    locum: locums.sample,
    owned_by: %w[agency client].sample,
    created_at: Time.current,
    updated_at: Time.current
  )

  puts "Created job ##{i+1}: #{job.start.strftime('%a, %b %d %H:%M')} - #{job.end.strftime('%H:%M')} at #{job.client.name}"
end

puts "\nSuccessfully created 20 jobs for #{Date::MONTHNAMES[current_month.month]} #{current_month.year}"
puts "- #{agencies.count} agencies"
puts "- #{clients.count} clients"
puts "- #{locums.count} locums"
