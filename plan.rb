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
end_date = nil


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

        --race-date -r:
            When does the race starts [mm/dd/yyyy]

        --start-date -s:
           Training start date, now (default) [mm/dd/yyyy]."

      exit 0
    when '--time'
      time = arg.scan(/(\d{2}):(\d{2})/).collect{ $1.to_i*60 + $2.to_i }.first
    when '--race-date'
      end_date = Date.parse(arg)
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


duration_in_weeks = training_plan.weeks.length

if (!end_date.nil?)
  start_date = end_date - (duration_in_weeks - 1) * 7
else
  end_date = start_date + (duration_in_weeks - 1) * 7
end

paces = Paces.new(time)
puts "Training Program for %s with a %s 5K time" % [training_plan.name, Utils.sec_to_mmss(time)]
puts "Start-Date: #{start_date}"

#TODO:
#1.support the case where the race date is beyond the end of the program
#2. improve the week/days calculations (there is a bug right now with the race_date week) and move to utils

puts "Program will end on: #{end_date}"
puts "Program length: #{duration_in_weeks} weeks out of #{training_plan.weeks.length} weeks"

plan = training_plan.weeks.slice(-training_plan.weeks.length, duration_in_weeks)
plan.each{ |program|
  week_start_day = Date.commercial(start_date.cwyear, start_date.cweek + (plan.length - program.week), 1)
  
  puts
  puts "Week #{program.week} of #{training_plan.weeks.length}"
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
