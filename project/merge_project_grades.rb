require 'csv'
require_relative '../csv_helpers'

project_roster_file = File.expand_path('../group_roster.csv', __FILE__)
iteration_grades_file = File.expand_path('../iteration_grades.csv', __FILE__)

project_grades_output_file = File.expand_path('../merged_project_grades.csv', __FILE__)

PROJECT_GRADES = ['iter0-2', 'iter0-3', 'iter1-2', 'iter2-2', 'iter3-2']

@groups = CSV.load_hash project_roster_file, 'Group Number', [
  'Student 1',
  'Student 2',
  'Student 3',
  'Student 4',
  'Student 5',
  'Student 6'
]

@project_grades = {}
CSV.foreach iteration_grades_file, :headers => true, :return_headers => false do |row|
  group_num = row['Group Number']
  members = @groups[group_num]
  members.each do |member|
    next if member.nil? || member.empty?
    @project_grades[member] ||= {}
    PROJECT_GRADES.each do |proj|
      @project_grades[member][proj] = row[proj]
    end
  end
end

rows = []
@project_grades.each do |name, grades|
  rows << [name] + PROJECT_GRADES.map do |assign|
    grades[assign]
  end
end

CSV.dump_array project_grades_output_file, rows, ['Name'] + PROJECT_GRADES
