# Returns a file containing student names and their corresponding multiple choice grade
# to input into Pandagrader

require 'csv'
require_relative '../csv_helpers'

# multiple_choice_grades_file = 'mult_choice_grades.csv'
# frq_grades_file = 'midterm1_grades.csv'
# 
# merged_grades_file = 'multiple_choice_with_names.csv'
# 
# mult_choice_grades = CSV.load_hash multiple_choice_grades_file, 'SID', 'Mark'
# 
# values = []
# CSV.foreach frq_grades_file, :headers => true, :return_headers => false do |row|
#     if mult_choice_grades.has_key? row['SID']
#         values << [row['Name'], mult_choice_grades[row['SID']]] 
#     end
# end
# 
# CSV.dump_array merged_grades_file, values.sort

midterm1_grades_file = File.expand_path('../midterm1_scores.csv', __FILE__)
midterm2_grades_file = File.expand_path('../midterm2_scores.csv', __FILE__)

midterm_grades_ouput_file = File.expand_path('../midterm_grades.csv', __FILE__)

midterm2_grades = CSV.load_hash midterm2_grades_file, 'SID', 'Mark'

values = []
CSV.foreach midterm1_grades_file, :headers => true, :return_headers => false do |row|
  values << [
    row['Name'],
    row['SID'],
    row['Total Score'],
    midterm2_grades[row['SID']]
  ]
end

CSV.dump_array midterm_grades_ouput_file, values, ['Name', 'SID', 'midterm1', 'midterm2']
