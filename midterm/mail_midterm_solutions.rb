require 'rubygems'
require 'gmail'

solution_files_dir = File.expand_path('../midterm2_solutions', __FILE__)

def usage
  STDERR.puts <<EndOfHelp
Usage: ruby #{$0} GMAIL_USERNAME GMAIL_PASSWORD
EndOfHelp
  exit
end

usage if ARGV.length < 2
username = ARGV[0]
password = ARGV[1]

message_subject = 'Midterm 2 Solutions'
message_body = %Q{
Dear student,

We've included the solutions for midterm 2 in a watermarked PDF. These solutions are meant solely for your use and not meant to be distributed, shared, or posted online, in any way, shape, or form.

PLEASE DO NOT DISTRIBUTE.

Your scans will be made available to you at a later date.
If you feel there has been an error in the grading of your midterm, or you do not see a score on glookup for your midterm2, please email me at alechoey@berkeley.edu

Sincerely,
The CS169 Staff
}

Gmail.new(username, password) do |gmail|
  Dir.foreach(solution_files_dir) do |solution|
    next unless solution =~ /mt2sol_(.*)\.pdf/i
    email = $1
    gmail.deliver do
      to email
      subject message_subject
      text_part do
        body message_body
      end
      add_file File.expand_path(solution, solution_files_dir)
    end
  end
end
