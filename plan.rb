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

require './kr_data.rb'
require './programs.rb'
require 'getoptlong'


# Format a number of seconds into mm:ss format. Easier for workout input/human
def sec_to_mmss(seconds)
  mm = (seconds / 60).to_i
  ss = seconds.remainder(60).to_i
  "%d:%02d" % [mm, ss]
end

def format_pace(distance, type, paces)
  sec_to_mmss(get_pace(distance, type, paces))
end


def display_session(step, paces)
  if (step.kind_of?(Interval))
    duration = (step.type === DurationType::KILOMETERS && ("%.1f%s" % [step.duration, 'km']) || ("%02d%s" % [step.duration/60, 'min']) )
    pace = format_pace(step.duration, step.target, paces)
    "Interval: %s @ %s" % [ duration, pace ]
  elsif (step.kind_of?(Recovery))
    duration = (step.type === DurationType::KILOMETERS && ("%.1f%s" % [step.duration, 'km']) || ("%02d%s" % [step.duration, 's']) )
    "RI %s" % duration
  elsif (step.kind_of?(Repeat))
    "#{step.repeat} x (%s)" % step.steps.map{ |s| display_session(s, paces) }.join(' - ')
  else
    raise "Invalid step: #{step.inspect}"
  end
end


# Sample. Let's assume 24 minutes for 5K
time = 24*60

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--time', '-t', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--program', '-p', GetoptLong::OPTIONAL_ARGUMENT ]
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
   The program name: 5k, 10k, half-marathon, novice-marathon, marathon

"
      exit 0
    when '--time'
      time = arg.scan(/(\d{2}):(\d{2})/).collect{ $1.to_i*60 + $2.to_i }.first
    when '--name'
      # FIXME program
  end
end

paces = Paces.new(time)

# display that for validation
puts "Training Program for Half-Marathon with a %s 5K time" % sec_to_mmss(time)
Program::HALF_MARATHON.each{ |program|
  puts "Week #{program.week}"
  puts "  KR1"
  program.kr1.steps.each{ | step |
    puts "    %s" % display_session(step, paces)
  }
  puts "  KR2"
  program.kr2.steps.each{ | step |
    puts "    %s" % display_session(step, paces)
  }
  puts "  KR3"
  program.kr3.steps.each{ | step |
    puts "    %s" % display_session(step, paces)
  }  
  puts ""
}
