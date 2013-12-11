require 'csv'
require 'yaml'
require 'psych'

raw_grades_file = File.expand_path('../output/raw_grades.csv', __FILE__)
config_file = File.expand_path('../input/config.yml', __FILE__)
final_grades_file = File.expand_path('../output/final_grades.csv', __FILE__)

@config = YAML.load_file config_file
@header = []
@weighted_grades = []
CSV.foreach raw_grades_file, :headers => :first_row, :return_headers => true do |row|
  if row.header_row?
    @header = row.headers
    next
  end

  weighted_grade = {}
  weighted_total = 0
  @header.each do |header|
    weighted_grade[header] = row[header]
  end

  @config.each do |assignment|
    name = assignment['name']
    max_points = assignment['max_points']
    weight = assignment['weight']
    raw_score = weighted_grade[name].to_f
    weighted_assignment = raw_score / max_points * 100
    weighted_grade[name] = weighted_assignment
    weighted_total += weighted_assignment * weight
  end
  weighted_grade['Total'] = weighted_total
  @weighted_grades << weighted_grade
end

CSV.open final_grades_file, 'wb' do |csv|
  @header ||= []
  @header += ['Total']
  csv << @header
  @weighted_grades.each do |grade|
    csv << @header.map { |header| grade[header] }
  end
end
