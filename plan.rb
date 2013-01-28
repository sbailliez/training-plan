#!/usr/bin/ruby
#
# Displays a training plan for half-marathon using the data from the FIRST program presented
# in Runner's World book 'Run Less, Run Faster'.
#
# If I can make this script half decent, I'll try to generalize it for the 5K, 10K and marathon
# for now this is mostly experimental.
#
# Ideally it would be nice to spit out the training plan in TCX format too, as it is a massive pain
# to enter all this data manually into Garmin Connect website or Garmin Training Center.
#
#
require "./utils.rb"
require './kr_data.rb'
require './programs.rb'
require 'getoptlong'
require 'date'

# Sample. Let's assume 24 minutes for 5K
time = 24*60
training_plan = Program::HALF_MARATHON
start_date = Date.today()
race_date_override = nil


opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--time', '-t', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--program', '-p', GetoptLong::OPTIONAL_ARGUMENT],
  [ '--race-date', '-r', GetoptLong::REQUIRED_ARGUMENT],
  [ '--start-date', '-s', GetoptLong::REQUIRED_ARGUMENT]
)

opts.each do |opt, arg|
  case opt
    when '--help'
      puts "plan [OPTION]
        -h, --help:
           show help

        --time t, -t t:
           5K time as mm:ss format. eg 22:35

        --program [name]:
           The program name: 5k, 10k, half-marathon (default), novice-marathon, marathon

        --race-day -r:
            When does the race starts [mm/dd/yyyy]

        --start day -s:
           Training start date, now (default) [mm/dd/yyyy]."

      exit 0
    when '--time'
      time = arg.scan(/(\d{2}):(\d{2})/).collect{ $1.to_i*60 + $2.to_i }.first
    when '--race-date'
      race_date_override = Date.parse(arg)
    when '--start-date'
      start_date = Date.parse(arg)
    when '--program'
      training_plan = case arg
        when '5k' then Program::KM5
        when '10k'then Program::KM10
        when 'half-marathon' then Program::HALF_MARATHON
        when 'novice-marathon' then Program::NOVICE_MARATHON
        when 'marathon' then Program::MARATHON
        else raise "Invalid program name: '%s'" % arg
      end
  end
end

paces = Paces.new(time)
puts "Training Program for %s with a %s 5K time" % [training_plan.name, Utils.sec_to_mmss(time)]
puts "Start-Date: #{start_date}"

#TODO:
#1.support the case where the race date is beyond the end of the program
#2. improve the week/days calculations (there is a bug right now with the race_date week) and move to utils

number_weeks = nil
program_end_date = nil
normalize_week_count = 0
unless race_date_override.nil?
  number_weeks = race_date_override.cweek - start_date.cweek + 1
  program_end_date = Date.commercial(race_date_override.cwyear, race_date_override.cweek, 1)
  puts "Race Day: #{race_date_override}"
  puts "program original length: #{training_plan.weeks.length} weeks"
  if (number_weeks < training_plan.weeks.length)
    normalize_week_count = training_plan.weeks.length - number_weeks
    puts "but you will only have #{number_weeks} weeks"
  end
else
  number_weeks = training_plan.weeks.length
  program_end_date = start_date + (number_weeks - 1) * 7
  puts "program will end on: #{program_end_date}"
  puts "program length: #{number_weeks} weeks"
end

training_plan.weeks.each{ |program|
  #Exit once all the weeks that the user has time to train have been printed
  exit 0 if (program.week - normalize_week_count <= 0)
puts "------------------------------------------------------------"

  week_start_day = Date.commercial(program_end_date.cwyear,
    program_end_date.cweek - (number_weeks - program.week + normalize_week_count), 1)

  puts "# #{program.week - normalize_week_count} - #{week_start_day}  "
  puts "  KR1 #{week_start_day}"
  program.kr1.steps.each{ | step |
    puts "    %s" % Utils.display_session(step, paces)
  }
  puts "  KR2 #{week_start_day + 2}"
  program.kr2.steps.each{ | step |
    puts "    %s" % Utils.display_session(step, paces)
  }
  puts "  KR3 #{week_start_day + 4}"
  program.kr3.steps.each{ | step |
    puts "    %s" % Utils.display_session(step, paces)
  }
}
