require 'dotenv'
Dotenv.load

service_account_email = ENV['service_account_email']
service_account_key = ENV['service_account_key']

puts "service_account_email: #{service_account_email}"
puts "service_account_key: #{service_account_key}"
