#/bin/ruby

require 'csv'
require_relative 'csv_helpers'

midterm1_grades_file = 'midterm1/midterm1_grades.csv'
edx_usernames_file = 'input/edx_usernames.csv'
homework_grades_file = 'input/edx_grades.csv'

# Output files
merged_grades_file = 'output/final_grades.csv'
missing_usernames_file = 'output/missing_usernames.txt'
missing_names_file = 'output/missing_names.txt'

# Map from edX name to Pandagrader name for names that need to be manually matched
name_map_file = 'mismatched_names.csv'

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
        midterm_grade
    ]
    merged_grades << grade_entry
end

CSV.open(merged_grades_file, 'wb') do |csv|
    csv << ['SID', 'hw0', 'hw1', 'hw1.5', 'hw2', 'hw3', 'hw4', 'midterm1']
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
