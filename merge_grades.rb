#/bin/ruby

require 'csv'
require_relative 'csv_helpers'

midterm1_grades_file = File.expand_path('../midterm1/midterm1_grades.csv', __FILE__)
edx_usernames_file = File.expand_path('../input/edx_usernames.csv', __FILE__)
homework_grades_file = File.expand_path('../input/edx_grades.csv', __FILE__)

# Output files
merged_grades_file = File.expand_path('../output/final_grades.csv', __FILE__)
missing_usernames_file = File.expand_path('../output/missing_usernames.txt', __FILE__)
missing_names_file = File.expand_path('../output/missing_names.txt', __FILE__)

# Map from edX name to Pandagrader name for names that need to be manually matched
name_map_file = File.expand_path('../input/mismatched_names.csv', __FILE__)

midterm_grades = CSV.load_hash midterm1_grades_file, 'Name', ['SID', 'Total Score'], NameHash.new
edx_usernames = CSV.load_hash edx_usernames_file, 'Username', 'Full Name'
mismatched_names = CSV.load_hash name_map_file, 'edX Name', 'Pandagrader Name'

merged_grades = []
usernames_not_found = []
names_not_found = []
CSV.foreach(homework_grades_file, :headers => true, :return_headers => false) do |row|
    username = row['Username']
    name = edx_usernames[username]
    if name.nil?
        usernames_not_found << username
        next 
    end

    midterm_grade_row = midterm_grades[name]
    if midterm_grade_row.nil? && mismatched_names.has_key?(name)
        pandagrader_name = mismatched_names[name]
        midterm_grade_row = midterm_grades[pandagrader_name]
    end
    if midterm_grade_row.nil?
        names_not_found << name
        next 
    end

    sid = midterm_grade_row[0]
    midterm_grade = midterm_grade_row[1]
    grade_entry = [
        sid,
        row['hw0'],
        row['hw1'],
        row['hw1.5'],
        row['hw2'],
        row['hw3'],
        row['hw4'],
        row['hw5a'],
        row['hw5b'],
        midterm_grade
    ]
    merged_grades << grade_entry
end

CSV.open(merged_grades_file, 'wb') do |csv|
    csv << ['SID', 'hw0', 'hw1', 'hw1.5', 'hw2', 'hw3', 'hw4', 'hw5a', 'hw5b', 'midterm1']
    merged_grades.each do |grade|
        csv << grade
    end
end

unless usernames_not_found.empty?
    File.open(missing_usernames_file, 'w') do |f|
        usernames_not_found.each do |username|
            f.write("#{username}\n")
        end
    end
    puts "Dumped #{usernames_not_found.count} missing usernames into #{missing_usernames_file}"
else
    File.delete missing_usernames_file
    puts 'No usernames were missing'
end

unless names_not_found.empty?
    File.open(missing_names_file, 'w') do |f|
        names_not_found.each do |name|
            f.write("#{name}\n")
        end
    end
    puts "Dumped #{names_not_found.count} missing names into #{missing_names_file}"
else
    File.delete missing_names_file
    puts 'No names were missing'
end
