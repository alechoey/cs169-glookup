CS169 Glookup
=============

Scripts to merge grades between edX, midterms, and projects and to generate graded roster files that can be entered in glookup.

The scripts work on the following directory tree:
```sh
hw/
	config/
		hw*.yml
input/
    edx_grades.csv
    edx_usernames.csv
    mismatched_names.csv
    roster
output/
    final_grades.csv
    missing_names.txt
    missing_usernames.txt
```

Input Data
==========

**hw/config/hw\*.yml** are YAML configuration files for scraping homeworks from edX. Each file contains the edX ID's for the problems of interest, the point values, the due date, and other necessary information to calculate the score.

**input/edx\_grades.csv** is a CSV file containing a student's username and their corresponding grades for the homeworks and a column following each assignment that lists the number of days that the student is late. Right now, these are generated by George Yiu in some mystery script.

**input/edx\_usernames.csv** is a simple CSV file that lists a student's username, name, and email, which is used to join between homeworks and midterm grades.

**input/mismatched\_names.csv** is a CSV that is manually edited to help match names between edX and Bearfacts, which is used by the midterm grades that are from Pandagrader. Since some names are different (Nick vs Nicholas), this file covers the cases that can't be programattically joined by the scripts.

**input/roster** is a text file of INST logins, names, and SIDs, which is joined with grades to output a graded roster that is loaded into glookup.

Output Data
===========

**output/final\_grades.csv** is the merged spreadsheet that contains SID's and the grades for all assignments, midterms, and projects.

**output/missing\_names.txt** is a list of names in edX that do not appear in Bearfacts. Use this to manually adjust input/mismatched\_names.csv to match names between edX and Bearfacts. Keep in mind that extra users (edX people, dropped students, and instructors) also are in edX, but not Bearfacts, so it's unlikely that this file will be completely empty.

**output/missing\_usernames.txt** is a list of edX usernames in input/edx\_grades.csv that don't have a corresponding entry in input/edx\_usernames.csv.

The Scripts
===========
**generate\_roster.rb** takes in a blank roster file and an assignment and outputs a graded roster file that can be inputted into glookup. It can optinally also take a maximum scores to reweight the scores (i.e. from out of 500 to out of 100).

```sh
Example:
ruby generate_roster input/roster hw0 300 100
```

**hw/collect\_hw\_grades.rb** finds all the config files in hw/config/*yml and scrapes edX for submissions for each of the assignments given in the configuration file using the "Watir" gem and Google Chrome Webdriver. See hw/collect\_hw\_grades.rb on how to install these.

**merge\_grades.csv** takes a spreadsheet of homework grades and spreadsheets of midterm grades and outputs a merged spreadsheet of combined grades for each student. It can also take a list of names that need to manually matched between edX and Bearfacts, though the script tries to programatticaly match most cases.


**strip\_edx\_usernames.csv** is a simple script that takes a spreadsheet from edX and pulls the username, name, and email and outputs them into another spreadsheet.

  [alec hoey]: http://github.com/alechoey
  [1]: http://daringfireball.net/projects/markdown/
  [Marked]: https://github.com/chjj/marked
  [ace editor]: http://ace.ajax.org
  [node.js]: http://nodejs.org
  [Twitter Bootstrap]: http://twitter.github.com/bootstrap/
  [keymaster.js]: https://github.com/madrobby/keymaster
  [jQuery]: http://jquery.com  
  [@tjholowaychuk]: http://twitter.com/tjholowaychuk
  [express]: http://expressjs.com
