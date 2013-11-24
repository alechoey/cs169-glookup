#/bin/ruby

# This script uses the 'watir' gem
# http://watir.com/
# and the Google Chrome Webdriver.
# Download the newest version for your system here:
# http://chromedriver.storage.googleapis.com/index.html

# This script also uses a set of YAML configuration files,
# one for each assignment, containing the due dates, edX IDs,
# and points assigned to each section of the assignment.
# This script will automatically collect the maximum score for each
# part of the assignment, taking into account late penalties too.

require 'rubygems'
require 'watir-webdriver'

require 'csv'
require 'yaml'
require 'psych'
require 'uri'

edx_usernames_file = File.expand_path('../../input/edx_usernames.csv', __FILE__)
hw_config_path = File.expand_path('../config/*.yml', __FILE__)
output_path = File.expand_path('../../input/edx_grades.csv', __FILE__)
 
EDX_BASE_URL = 'https://edge.edx.org'

GRACE_PERIOD = 600 # in seconds
DEFAULT_LATE_PENALTY = 0.25 # 25% per day
ASSIGNMENT_NAMES = ['hw0', 'hw1', 'hw1.5', 'hw2', 'hw3', 'hw4', 'hw5a', 'hw5b']

def usage
  STDERR.puts <<EndOfHelp
Usage: ruby #{$0} ADMIN_EMAIL ADMIN_PASSWORD 

Collects homework grades from edX and outputs a spreadsheet, taking into account highest homework grades and late penalties.
EndOfHelp
  exit
end

module URI
  def self.join(*segments)
    segments.map(&:to_s).join('/')
  end
end

def load_yaml_file(filename)
  def validate_yaml_has_key(yaml, key)
    unless yaml.has_key? key
      puts "#{filename} must include a #{key}"
      exit
    end
  end

  yaml = YAML.load_file filename
  validate_yaml_has_key yaml, 'name'
  validate_yaml_has_key yaml, 'class_id'
  validate_yaml_has_key yaml, 'due_date'
  validate_yaml_has_key yaml, 'modules'
  if yaml['modules'].empty?
    puts "#{filename} YAML must have at least one module"
    exit
  end
  yaml['modules'].each do |mod|
    validate_yaml_has_key mod, 'id'
    validate_yaml_has_key mod, 'points'
  end
  yaml
end

def find_score(browser, config)
  max_score = 0
  browser.divs.each do |div|
    html = div.html
    if html =~ /<b>#[0-9]+<\/b>:\s([0-9\-:\s\+]+).*<br>/
      submission_time = Time.new($1)
    else
      next
    end

    if html =~ /Score:\s([0-9\.]+)\s\/\s([0-9\.]+)/
      raw_score = $1.to_f
    else
      next
    end

    lateness = submission_time - config['due_date'] - GRACE_PERIOD
    days_late = (lateness < 0 ? 0 : lateness / 1.day).ceil
    late_penalty = (config['late_penalty'] || DEFAULT_LATE_PENALTY).to_f
    weighted_score = raw_score - days_late * late_penalty
    max_score = weighted_score if weighted_score > max_score
  end
  max_score
end

usage if ARGV.count < 2
admin_email = ARGV[0]
admin_password = ARGV[1]

browser = Watir::Browser.new :chrome
browser.goto EDX_BASE_URL

login_form = browser.form(:id => 'login_form')
login_form.text_field(:name => 'email').set admin_email
login_form.text_field(:name => 'password').set admin_password
login_form.submit

Watir::Wait.until { browser.title == 'Dashboard' }

scores = {}

Dir.glob hw_config_path do |yaml|
  config = load_yaml_file yaml
  base_uri = URI.join EDX_BASE_URL, 'courses', config['class_id'], 'submission_history'
  CSV.foreach edx_usernames_file, :headers => true, :return_headers => false do |row|
    username = row['Username']
    hw_grade = 0
    config['modules'].each do |mod|
      id = mod['id']
      submissions_uri = URI.join base_uri, username, id
      browser.goto submissions_uri
      hw_grade += find_score browser, config
    end
    scores[username] ||= {'Username' => username}
    scores[username][config['name']] = hw_grade
  end
end

csv_header = Array.new(ASSIGNMENT_NAMES).unshift 'Username'
CSV.open output_path, 'wb', :headers => csv_header, :return_headers => true, :write_headers => true do |csv|
  scores.each do |username, user_scores|
    row_vals = Array.new(csv_header.count)
    csv_header.each_with_index do |header, idx|
      row_vals[idx] = user_scores[header] if user_scores.has_key? header
    end
    row = CSV::Row.new csv_header, row_vals
    csv << row
  end
end
