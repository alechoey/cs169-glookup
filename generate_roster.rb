require 'csv'
require 'yaml'
require 'psych'
require_relative 'csv_helpers'

merged_grades_file = File.expand_path('../output/raw_grades.csv', __FILE__)
config_file = File.expand_path('../input/config.yml', __FILE__)
@roster_file = File.expand_path('../input/roster', __FILE__)

def write_roster_to_file(file, config)
  assignment = config['name']
  max_points = config['max_points']
  scale_for_glookup = config['scale_for_glookup']
  File.open(@roster_file, 'r') do |roster|
    File.open(file, 'wb') do |new_roster|
      roster.each_line do |line|
        if line =~ /(cs169-[a-z]{2})\s+(.*)\s+([0-9]{7,8})/
          login = $1
          name = $2
          sid = $3
          student_grades = @raw_grades[sid]
          if student_grades.nil? 
            puts "#{name} with SID #{sid} is missing #{assignment} grade"
            next
          end

          raw_score = student_grades[assignment].to_f
          score = (scale_for_glookup ? raw_score / max_points * 100 : raw_score)
          new_line = "#{login} #{name.gsub /\ /, '_'} #{score}\n"
          new_roster.write new_line
        end
      end
    end
  end
end

@config = YAML.load_file config_file
@assignments = @config.map { |assignment| assignment['name'] }

@raw_grades = CSV.load_hash merged_grades_file, 'SID', @assignments, :value_type => Hash

@config.each do |config|
  assignment = config['name']
  graded_roster_file = File.expand_path("../output/#{assignment}_roster", __FILE__)
  write_roster_to_file(graded_roster_file, config) 
end
