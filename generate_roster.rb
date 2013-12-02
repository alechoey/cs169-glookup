#/bin/ruby

require 'csv'
require_relative 'csv_helpers'

def usage
  STDERR.puts <<EndOfHelp
Usage: ruby #{$0} ROSTER MERGED_GRADES ASSIGNMENT_ID [UNWEIGHTED_MAX] [WEIGHTED_MAX]

Ex: ruby #{$0} input/roster output/final_grades.csv hw0 300 100

Creates a roster populated with the grades for the given assignemnt for entering into glookup
EndOfHelp
  exit
end

usage if ARGV.count < 3
roster_file = ARGV[0]
merged_grades_file = ARGV[1]
assignment_id = ARGV[2]
unweighted_max = ARGV[3] || 100
weighted_max = ARGV[4] || 100


graded_roster_file = File.expand_path("../../output/#{assignment_id}_roster", roster_file)
assignment_grades = CSV.load_hash merged_grades_file, 'SID', assignment_id

File.open(roster_file, 'r') do |roster|
    File.open(graded_roster_file, 'wb') do |new_roster|
        roster.each_line do |line|
            if line =~ /(cs169-[a-z]{2})\s+(.*)\s+([0-9]{7,8})/
                login = $1
                name = $2
                sid = $3
                assignment_grade = assignment_grades[sid]
                if assignment_grade.nil?
                    puts "#{name} with SID #{sid} is missing #{assignment_id} grade"
                    next
                end

                weighted_score = assignment_grade.to_f * weighted_max.to_f
                weighted_score /= unweighted_max.to_f
                new_line = "#{login} #{name.gsub /\ /, '_'} #{weighted_score}\n"
                new_roster.write new_line
            end
        end
    end
end
