#/bin/ruby

require 'csv'
require_relative 'csv_helpers'

HOMEWORKS = ['hw0', 'hw1', 'hw1.5', 'hw2', 'hw3', 'hw4', 'hw5a', 'hw5b']
PROJECTS = []
MIDTERMS = ['midterm1']
ASSIGNMENTS = HOMEWORKS + PROJECTS +  MIDTERMS
MERGED_CSV_HEADER = ['Name', 'SID'] + ASSIGNMENTS

midterm1_grades_file = File.expand_path('../midterm1/midterm1_grades.csv', __FILE__)
edx_usernames_file = File.expand_path('../input/edx_usernames.csv', __FILE__)
homework_grades_file = File.expand_path('../input/edx_grades.csv', __FILE__)

# Output files
merged_grades_file = File.expand_path('../output/final_grades.csv', __FILE__)
missing_usernames_file = File.expand_path('../output/missing_usernames.txt', __FILE__)
missing_names_file = File.expand_path('../output/missing_names.txt', __FILE__)

# Map from edX name to Pandagrader name for names that need to be manually matched
mismatched_names_file = File.expand_path('../input/mismatched_names.csv', __FILE__)

# File of manual grade adjustments
manual_grade_adjustments_file = File.expand_path('../input/manual_grade_adjustments.csv', __FILE__)

@midterm_grades = CSV.load_hash midterm1_grades_file, 'Name', ['SID', 'Total Score'], NameHash.new
@edx_usernames = CSV.load_hash edx_usernames_file, 'Username', 'Full Name'

if File.exists? mismatched_names_file
  mismatched_names = CSV.load_hash mismatched_names_file, 'edX Name', 'Pandagrader Name'

  mismatched_names_to_grades = {}
  mismatched_names.each do |edx_name, panda_name|
    mismatched_names_to_grades[edx_name] = @midterm_grades[panda_name]
  end
  @midterm_grades.merge! mismatched_names_to_grades
end

merged_grades = {}
usernames_not_found = []
names_not_found = []
CSV.foreach(homework_grades_file, :headers => true, :return_headers => false) do |row|
  username = row['Username']
  name = @edx_usernames[username]
  if name.nil?
    usernames_not_found << username
    next 
  end

  midterm_grade_row = @midterm_grades[name]
  if midterm_grade_row.nil?
    names_not_found << name
    next 
  end

  sid = midterm_grade_row[0]
  midterm_grade = midterm_grade_row[1]
  grade_entry = { 'Name' => name, 'SID' => sid, 'midterm1' => midterm_grade }
  HOMEWORKS.each do |assign|
    grade_entry[assign] = row[assign]
  end
  merged_grades[sid] = grade_entry
end

if File.exists? manual_grade_adjustments_file
  CSV.foreach(manual_grade_adjustments_file, :headers => true, :return_headers => false) do |row|
    name = row['Name']
    midterm_grade_row = @midterm_grades[name]
    sid = midterm_grade_row[0]
    
    ASSIGNMENTS.each do |assign|
      next if row[assign].nil? || row[assign].empty?
      merged_grades[sid][assign] = row[assign]
    end
  end
end

CSV.open(merged_grades_file, 'wb') do |csv|
  csv << MERGED_CSV_HEADER
  merged_grades.each do |sid, grade_entry|
    row = []
    MERGED_CSV_HEADER.each do |header|
      row << grade_entry[header]
    end
    csv << row
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
  File.delete(missing_usernames_file) if File.exists? missing_usernames_file
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
  File.delete(missing_names_file) if File.exists? missing_names_file
  puts 'No names were missing'
end
