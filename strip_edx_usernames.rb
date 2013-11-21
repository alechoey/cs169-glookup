#/bin/ruby

require 'csv'

old_edx_file = 'input/old_edx_usernames.csv'
new_edx_file = 'input/edx_usernames.csv'

CSV.open(new_edx_file, 'wb') do |csv|
    headers = ["Username", "Full Name", "edX email"]
    csv << headers
    CSV.foreach(old_edx_file, :headers => true, :return_headers => false) do |row|
        csv << headers.map { |header| row[header] }
    end
end
