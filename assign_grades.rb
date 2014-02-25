require 'csv'
require_relative 'csv_helpers'

weighted_grades_file = File.expand_path('../output/final_grades.csv', __FILE__)
grade_cutoffs_file = File.expand_path('../input/grade_cutoffs.csv', __FILE__)

letter_grades_file = File.expand_path('../output/letter_grades.csv', __FILE__)

def load_cutoffs(cutoffs_file)
  temp_cutoffs = CSV.load_hash(cutoffs_file,
                                 'Cutoff',
                                 ['Grade', 'GPA'],
                                 :value_type => Hash)
  @grade_cutoffs = {}
  temp_cutoffs.each do |k,v|
    @grade_cutoffs[k.to_f] = v
  end
  @cutoffs = @grade_cutoffs.keys.map(&:to_f).sort_by { |cut| cut * -1 }
end

def find_grade_for_score(score)
  cutoff = @cutoffs.bsearch { |cutoff| cutoff <= score }
  grade_and_gpa = @grade_cutoffs[cutoff]
  @avg_gpa += grade_and_gpa['GPA'].to_f
  @student_count += 1
  grade_and_gpa['Grade']
end

@avg_gpa = 0
@student_count = 0
load_cutoffs grade_cutoffs_file
@grades = []
@header = ['Name', 'SID', 'Total', 'Grade']
  
CSV.foreach weighted_grades_file, :headers => true, :return_headers => false do |row|
  total = row['Total'].to_f
  grade = find_grade_for_score total
  @grades << [row['Name'], row['SID'], total, grade]
end

CSV.dump_array letter_grades_file, @grades.sort_by { |row| -row[2] }, @header

@avg_gpa /= @student_count
puts "Average GPA: #{@avg_gpa}"
