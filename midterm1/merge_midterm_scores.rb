#/bin/ruby

# Returns a file containing student names and their corresponding multiple choice grade
# to input into Pandagrader

require 'csv'
require_relative '../csv_helpers'

multiple_choice_grades_file = 'mult_choice_grades.csv'
frq_grades_file = 'midterm1_grades.csv'

merged_grades_file = 'multiple_choice_with_names.csv'

mult_choice_grades = CSV.load_hash multiple_choice_grades_file, 'SID', 'Mark'

values = []
CSV.foreach frq_grades_file, :headers => true, :return_headers => false do |row|
    if mult_choice_grades.has_key? row['SID']
        values << [row['Name'], mult_choice_grades[row['SID']]] 
    end
end

CSV.dump_array merged_grades_file, values.sort
