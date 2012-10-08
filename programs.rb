require './kr_data.rb'

# I'm defining everything as a Step object to represent Repeat, Recovery and Interval
class Step
  
end

class Repeat < Step
    attr_accessor :repeat, :steps
    def initialize(repeat, steps)
      @repeat = repeat
      @steps = steps
    end
end

module DurationType
  KILOMETERS = 1
  SECONDS = 2
end

# This could probably be made as an Interval with intensity 'Resting'
class Recovery < Step
  attr_accessor :duration, :type, :target
  def initialize(duration, type, target = PaceZone::NONE)
    @type = type
    @duration = duration
    @target = target
  end
  def self.distance(duration)
    Recovery.new(duration, DurationType::KILOMETERS)
  end
  
  def self.time(duration)
    Recovery.new(duration, DurationType::SECONDS)
  end
end


# Differing pace zones represented in the data table. There should be a better way to do this
# to avoid relying on some giant if/else to calculate pace, but this will do for now.
module PaceZone
  EASY = 1
  ST = 2
  MT = 3
  LT = 4
  HMP = 5
  HMP13 = 6
  HMP19 = 7
  MP = 8
  MP9 = 9
  MP12 = 10
  MP19 = 11
  MP28 = 12
  NONE = 99
end

# paces helper methods.
# TODO find a better way to write this. It is ugly.
class Paces
  attr_accessor :kr1, :kr2, :kr3
  def initialize(time)
    @kr1 = KeyRun::get_key_run_1(time)
    @kr2 = KeyRun::get_key_run_2(time)
    @kr3 = KeyRun::get_key_run_3(time)
  end
end

# return the pace base on distance, type and the selected paces structures for the given time
# TODO somewhat absurd way to do this... clean that up when possible
def get_pace(duration, type, paces)
  case type
  when PaceZone::HMP then paces.kr3.hmp
  when PaceZone::HMP13 then paces.kr3.hmp + 13
  when PaceZone::HMP19 then paces.kr3.hmp + 19
  when PaceZone::MP then paces.kr3.mp
  when PaceZone::MP9 then paces.kr3.mp + 9
  when PaceZone::MP12 then paces.kr3.mp + 12
  when PaceZone::MP19 then paces.kr3.mp + 19
  when PaceZone::MP28 then paces.kr3.mp + 28
  when PaceZone::ST then paces.kr2.st
  when PaceZone::MT then paces.kr2.mt
  when PaceZone::LT then paces.kr2.lt
  when PaceZone::EASY then paces.kr2.easy
  when PaceZone::NONE then
    case duration
    when 0.4 then paces.kr1.m400
    when 0.6 then paces.kr1.m600
    when 0.8 then paces.kr1.m800
    when 1.0 then paces.kr1.m1000
    when 1.2 then paces.kr1.m1200
    when 1.6 then paces.kr1.m1600
    when 2.0 then paces.kr1.m2000
    else paces.kr2.easy # default to easy if no pace given
    end
  else 
    raise "Invalid pace: #{distance} #{type}"
  end
end


# An interval is to be run for a given duration, the duration being either distance or time based.
class Duration
  attr_accessor :value, :unit
end

# time-based duration in seconds
class TimeDuration < Duration
  def initialize(value)
    @value = value
    @unit = DurationType::SECONDS
  end
end

# distance-based duration in kilometers
class DistanceDuration < Duration
  def initialize(value)
    @value = value
    @unit = DurationType::KILOMETERS
  end
end

# base class for target objectives
class Target
end

# simplest representation of a target will be at a given single pace
class Pace < Target
  def initialize(seconds)
    @seconds = seconds
  end
end

# no target, this means either jog or walk, usually used for rest/recovery intervals
class None < Target
end

# speedzone, this is normally the ideal way to represent the pace, in particular Garmin workout
# program will need to have a low/high value for the speed zone so that it can alert you if
# you're running outside the desired zone.
class SpeedZone < Target
  attr_accessor :low, :high # in meters per seconds
  def initialize(low, high)
    @low = low
    @high = high
  end
end

# Interval is an activity for a given duration, at a specific target
# TODO move duration/target to use the Duration type
class Interval < Step
  attr_accessor :duration, :target, :type
  def initialize(duration, type, target = PaceZone::NONE)
    @duration = duration
    @target = target
    @type = type
  end
  
  def self.distance(duration, target = PaceZone::NONE)
    Interval.new(duration, DurationType::KILOMETERS, target)
  end
  
  def self.time(duration, target = PaceZone::NONE)
    Interval.new(duration, DurationType::SECONDS, target)
  end
end

# a session is just a list of step, typically a session is just a key run
class Session
  attr_accessor :steps
  def initialize(steps)
    @steps = steps
  end
end

# Week program, made of 3 key runs
class WeekProgram
  attr_accessor :week, :kr1, :kr2, :kr3
  def initialize(week, kr1, kr2, kr3)
    @week = week
    @kr1 = kr1
    @kr2 = kr2
    @kr3 = kr3
  end
end

# Training plan
class TrainingPlan
  attr_accessor :weeks, :name
  def initialize(name, weeks)
    @name = name
    @weeks = weeks
  end
end

# Sample program, the representation of the half marathon program 16-week program
module Program
  
  KM5 = TrainingPlan.new("5K", [
    WeekProgram.new(12, 
      Session.new([ Interval.time(15*60),
        Repeat.new(8, [Interval.distance(0.4), Recovery.distance(0.4)]),
        Interval.time(10*60) ]),
      Session.new([ Interval.distance(3, PaceZone::ST) ]),
      Session.new([ Interval.distance(8, PaceZone::LT) ]) ),

    WeekProgram.new(11, 
      Session.new([ Interval.time(15*60),
        Repeat.new(5, [Interval.distance(0.8), Recovery.distance(0.4)]),
        Interval.time(10*60) ]),
      Session.new([ Interval.distance(5, PaceZone::ST) ]),
      Session.new([ Interval.distance(10, PaceZone::LT) ]) ),

    WeekProgram.new(10, 
      Session.new([ Interval.time(15*60),
        Repeat.new(2, [Interval.distance(1.6), Recovery.distance(0.4)]),
        Repeat.new(1, [Interval.distance(0.8), Recovery.distance(0.4)]),
        Interval.time(10*60) ]),
      Session.new([ Interval.distance(3, PaceZone::ST), Interval.distance(1.5, PaceZone::EASY), Interval.distance(3, PaceZone::ST) ]),
      Session.new([ Interval.distance(8, PaceZone::LT) ]) ),

    WeekProgram.new(9, 
      Session.new([ Interval.time(15*60),
        Interval.distance(0.4), Recovery.distance(0.4),
        Interval.distance(0.6), Recovery.distance(0.4),
        Interval.distance(0.8), Recovery.distance(0.4),
        Interval.distance(0.8), Recovery.distance(0.4),
        Interval.distance(0.6), Recovery.distance(0.4),
        Interval.distance(0.4), Recovery.distance(0.4),
        Interval.time(10*60) ]),
      Session.new([ Interval.distance(5, PaceZone::MT) ]),
      Session.new([ Interval.distance(10, PaceZone::LT) ]) ),

    WeekProgram.new(8, 
      Session.new([ Interval.time(15*60),
        Repeat.new(4, [Interval.distance(1.0), Recovery.distance(0.4)]),
        Interval.time(10*60) ]),
      Session.new([ Interval.distance(5, PaceZone::ST) ]),
      Session.new([ Interval.distance(11, PaceZone::LT) ]) ),

    WeekProgram.new(7, 
      Session.new([ Interval.time(15*60),
        Interval.distance(1.6), Recovery.distance(0.4),
        Interval.distance(1.2), Recovery.distance(0.4),
        Interval.distance(0.8), Recovery.distance(0.4),
        Interval.distance(0.4), Recovery.distance(0.4),
        Interval.time(10*60) ]),
      Session.new([ Interval.distance(1.5, PaceZone::ST), 
        Interval.distance(1.5, PaceZone::EASY),
        Interval.distance(1.5, PaceZone::ST),
        Interval.distance(1.5, PaceZone::EASY),
        Interval.distance(1.5, PaceZone::ST) ]),
      Session.new([ Interval.distance(10, PaceZone::LT) ]) ),

    WeekProgram.new(6, 
      Session.new([ Interval.time(15*60),
        Repeat.new(10, [Interval.distance(0.4), Recovery.time(90)]),
        Interval.time(10*60) ]),
      Session.new([ Interval.distance(6.5, PaceZone::MT) ]),
      Session.new([ Interval.distance(13, PaceZone::LT) ]) ),

    WeekProgram.new(5, 
      Session.new([ Interval.time(15*60),
        Repeat.new(6, [Interval.distance(0.8), Recovery.time(90)]),
        Interval.time(10*60) ]),
      Session.new([ Interval.distance(3, PaceZone::ST), Interval.distance(1.5, PaceZone::EASY), Interval.distance(3, PaceZone::ST) ]),
      Session.new([ Interval.distance(11, PaceZone::LT) ]) ),

    WeekProgram.new(4, 
      Session.new([ Interval.time(15*60),
        Repeat.new(4, [Interval.distance(1.2), Recovery.distance(400)]),
        Interval.time(10*60) ]),
      Session.new([ Interval.distance(5, PaceZone::ST) ]),
      Session.new([ Interval.distance(11, PaceZone::LT) ]) ),

    WeekProgram.new(3, 
      Session.new([ Interval.time(15*60),
        Repeat.new(5, [Interval.distance(1.0), Recovery.distance(400)]),
        Interval.time(10*60) ]),
      Session.new([ Interval.distance(3, PaceZone::ST), 
        Interval.distance(1.5, PaceZone::EASY),
        Interval.distance(1.5, PaceZone::ST),
        Interval.distance(1.5, PaceZone::EASY),
        Interval.distance(3, PaceZone::ST) ]),
      Session.new([ Interval.distance(11, PaceZone::LT) ]) ),

    WeekProgram.new(2, 
      Session.new([ Interval.time(15*60),
        Repeat.new(3, [Interval.distance(1.6), Recovery.distance(400)]),
        Interval.time(10*60) ]),
      Session.new([ Interval.distance(5, PaceZone::ST) ]),
      Session.new([ Interval.distance(10, PaceZone::LT) ]) ),

    WeekProgram.new(1, 
      Session.new([ Interval.time(15*60),
        Repeat.new(6, [Interval.distance(0.4), Recovery.time(60)]),
        Interval.time(10*60) ]),
      Session.new([ Interval.distance(5, PaceZone::EASY) ]),
      Session.new([ Interval.distance(5) ]) ),

    ])
    
  KM10 = TrainingPlan.new("10K", [
    WeekProgram.new(12, 
      Session.new([ Interval.time(15*60),
        Repeat.new(8, [Interval.distance(0.4), Recovery.distance(0.4)]),
        Interval.time(10*60) ]),
      Session.new([ Interval.distance(3, PaceZone::ST) ]),
      Session.new([ Interval.distance(10, PaceZone::LT) ]) ),

    WeekProgram.new(11, 
      Session.new([ Interval.time(15*60),
        Repeat.new(5, [Interval.distance(0.8), Recovery.distance(0.4)]),
        Interval.time(10*60) ]),
      Session.new([ Interval.distance(3, PaceZone::ST), Interval.distance(1.5, PaceZone::EASY), Interval.distance(3, PaceZone::ST) ]),
      Session.new([ Interval.distance(11, PaceZone::LT) ]) ),

    WeekProgram.new(10, 
      Session.new([ Interval.time(15*60),
        Repeat.new(2, [Interval.distance(1.6), Recovery.distance(0.4)]),
        Repeat.new(1, [Interval.distance(0.8), Recovery.distance(0.4)]),
        Interval.time(10*60) ]),
      Session.new([ Interval.distance(6.5, PaceZone::MT) ]),
      Session.new([ Interval.distance(13, PaceZone::LT) ]) ),

    WeekProgram.new(9, 
      Session.new([ Interval.time(15*60),
        Interval.distance(0.4), Recovery.distance(0.4),
        Interval.distance(0.6), Recovery.distance(0.4),
        Interval.distance(0.8), Recovery.distance(0.4),
        Interval.distance(0.8), Recovery.distance(0.4),
        Interval.distance(0.6), Recovery.distance(0.4),
        Interval.distance(0.4), Recovery.distance(0.4),
        Interval.time(10*60) ]),
      Session.new([ Interval.distance(3, PaceZone::ST), Interval.distance(1.5, PaceZone::EASY),
        Interval.distance(1.5, PaceZone::ST), Interval.distance(1.5, PaceZone::EASY),
        Interval.distance(3, PaceZone::ST) ]),
      Session.new([ Interval.distance(14, PaceZone::LT) ]) ),

    WeekProgram.new(8, 
      Session.new([ Interval.time(15*60),
        Repeat.new(4, [Interval.distance(1.0), Recovery.distance(0.4)]),
        Interval.time(10*60) ]),
      Session.new([ Interval.distance(6.5, PaceZone::ST) ]),
      Session.new([ Interval.distance(16, PaceZone::LT) ]) ),

    WeekProgram.new(7, 
      Session.new([ Interval.time(15*60),
        Interval.distance(1.6), Recovery.distance(0.4),
        Interval.distance(1.2), Recovery.distance(0.4),
        Interval.distance(0.8), Recovery.distance(0.4),
        Interval.distance(0.4), Recovery.distance(0.4),
        Interval.time(10*60) ]),
      Session.new([ Interval.distance(8, PaceZone::MT) ]),
      Session.new([ Interval.distance(13, PaceZone::LT) ]) ),

    WeekProgram.new(6, 
      Session.new([ Interval.time(15*60),
        Repeat.new(10, [Interval.distance(0.4), Recovery.time(90)]),
        Interval.time(10*60) ]),
      Session.new([ Interval.distance(6.5, PaceZone::ST) ]),
      Session.new([ Interval.distance(16, PaceZone::LT) ]) ),

    WeekProgram.new(5, 
      Session.new([ Interval.time(15*60),
        Repeat.new(6, [Interval.distance(0.8), Recovery.time(90)]),
        Interval.time(10*60) ]),
      Session.new([ Interval.distance(1.5, PaceZone::ST), Interval.distance(1.5, PaceZone::EASY), Interval.distance(3, PaceZone::ST),
        Interval.distance(1.5, PaceZone::EASY), Interval.distance(1.5, PaceZone::ST) ]),
      Session.new([ Interval.distance(13, PaceZone::LT) ]) ),

    WeekProgram.new(4, 
      Session.new([ Interval.time(15*60),
        Repeat.new(4, [Interval.distance(1.2), Recovery.distance(400)]),
        Interval.time(10*60) ]),
      Session.new([ Interval.distance(5, PaceZone::ST) ]),
      Session.new([ Interval.distance(16, PaceZone::LT) ]) ),

    WeekProgram.new(3, 
      Session.new([ Interval.time(15*60),
        Repeat.new(5, [Interval.distance(1.0), Recovery.distance(400)]),
        Interval.time(10*60) ]),
      Session.new([ Interval.distance(10, PaceZone::MT) ]),
      Session.new([ Interval.distance(13, PaceZone::LT) ]) ),

    WeekProgram.new(2, 
      Session.new([ Interval.time(15*60),
        Repeat.new(3, [Interval.distance(1.6), Recovery.distance(400)]),
        Interval.time(10*60) ]),
      Session.new([ Interval.distance(5, PaceZone::ST) ]),
      Session.new([ Interval.distance(11, PaceZone::LT) ]) ),

    WeekProgram.new(1, 
      Session.new([ Interval.time(15*60),
        Repeat.new(6, [Interval.distance(4), Recovery.time(60)]),
        Interval.time(10*60) ]),
      Session.new([ Interval.distance(5, PaceZone::EASY) ]),
      Session.new([ Interval.distance(10) ]) ),
    ])
  
  
  HALF_MARATHON = TrainingPlan.new("Half-Marathon", [  
  WeekProgram.new(16, 
    Session.new([ Interval.time(15*60),
      Repeat.new(12, [Interval.distance(0.4), Recovery.distance(0.4)]),
      Interval.time(10*60) ]),
    Session.new([ Interval.distance(3, PaceZone::EASY), Interval.distance(5, PaceZone::ST), Interval.distance(1.5, PaceZone::EASY) ]),
    Session.new([ Interval.distance(12.5, PaceZone::HMP13) ]) ),
  
  WeekProgram.new(15, 
    Session.new([ Interval.time(15*60),
      Interval.distance(0.4), Recovery.distance(0.4),
      Interval.distance(0.6), Recovery.distance(0.4),
      Interval.distance(0.8), Recovery.distance(0.4),
      Interval.distance(1.2), Recovery.distance(0.4),
      Interval.distance(0.8), Recovery.distance(0.4),
      Interval.distance(0.6), Recovery.distance(0.4),
      Interval.distance(0.4), Recovery.distance(0.4),
      Interval.time(10*60) ]),
    Session.new([ Interval.distance(3, PaceZone::EASY), Interval.distance(5, PaceZone::MT), Interval.distance(1.5, PaceZone::EASY) ]),
    Session.new([ Interval.distance(12.5, PaceZone::HMP13) ]) ),
  
  WeekProgram.new(14, 
    Session.new([ Interval.time(15*60), Repeat.new(6, [Interval.distance(0.8), Recovery.time(90)]), Interval.time(10*60) ]),
    Session.new([ Interval.distance(3, PaceZone::EASY), Interval.distance(5, PaceZone::ST), Interval.distance(1.5, PaceZone::EASY) ]),
    Session.new([ Interval.distance(16, PaceZone::EASY) ]) ),
  
  WeekProgram.new(13, 
    Session.new([ Interval.time(15*60), Repeat.new(5, [Interval.distance(1.0), Recovery.distance(0.4)]), Interval.time(10*60) ]),
    Session.new([ Interval.distance(3, PaceZone::EASY), Interval.distance(5, PaceZone::ST), Interval.distance(1.5, PaceZone::EASY) ]),
    Session.new([ Interval.distance(14, PaceZone::HMP13) ]) ),
  
  WeekProgram.new(12, 
    Session.new([ Interval.time(15*60), Repeat.new(3, [Interval.distance(1.6), Recovery.time(60)]), Interval.time(10*60) ]),
    Session.new([ Interval.distance(1.5, PaceZone::EASY), Interval.distance(10, PaceZone::LT), Interval.distance(1.5, PaceZone::EASY) ]),
    Session.new([ Interval.distance(18, PaceZone::HMP19) ]) ),
  
  WeekProgram.new(11, 
    Session.new([ Interval.time(15*60),
      Repeat.new(2, [Interval.distance(1.2), Recovery.time(120)]),
      Repeat.new(4, [Interval.distance(0.8), Recovery.time(120)]),
      Interval.time(10*60) ]),
    Session.new([ Interval.distance(1.5, PaceZone::EASY), Interval.distance(3, PaceZone::MT), Interval.distance(1.5, PaceZone::EASY),
       Interval.distance(3, PaceZone::MT), Interval.distance(1.5, PaceZone::EASY) ]),
    Session.new([ Interval.distance(16, PaceZone::HMP13) ]) ),
  
  WeekProgram.new(10, 
    Session.new([ Interval.time(15*60),
      Repeat.new(6, [Interval.distance(0.8), Recovery.time(90)]),
      Interval.time(10*60) ]),
    Session.new([ Interval.distance(1.5, PaceZone::EASY), Interval.distance(8, PaceZone::MT), Interval.distance(1.5, PaceZone::EASY) ]),
    Session.new([ Interval.distance(19, PaceZone::HMP19) ]) ),
  
  WeekProgram.new(9, 
    Session.new([ Interval.time(15*60),
      Repeat.new(6, [Interval.distance(0.4), Recovery.time(90)]),
      Recovery.time(150), Repeat.new(6, [Interval.distance(0.4), Recovery.time(90)]), Interval.time(10*60) ]),
    Session.new([ Interval.distance(1.5, PaceZone::EASY), Interval.distance(3, PaceZone::MT), Interval.distance(1.5, PaceZone::EASY),
       Interval.distance(3, PaceZone::MT), Interval.distance(1.5, PaceZone::EASY) ]),
    Session.new([ Interval.distance(12.5, PaceZone::HMP13) ]) ),

  WeekProgram.new(8, 
    Session.new([ Interval.time(15*60),
      Repeat.new(2, [Interval.distance(1.6), Recovery.time(60)]),
      Repeat.new(2, [Interval.distance(0.8), Recovery.time(60)]),
      Interval.time(10*60) ]),
    Session.new([ Interval.distance(1.5, PaceZone::EASY), Interval.distance(8, PaceZone::MT), Interval.distance(1.5, PaceZone::EASY) ]),
    Session.new([ Interval.distance(21, PaceZone::HMP13) ]) ),


  WeekProgram.new(7, 
    Session.new([ Interval.time(15*60),
      Repeat.new(4, [Interval.distance(1.2), Recovery.time(120)]),
      Interval.time(10*60) ]),
    Session.new([ Interval.distance(1.5, PaceZone::EASY), Interval.distance(10, PaceZone::MT), Interval.distance(1.5, PaceZone::EASY) ]),
    Session.new([ Interval.distance(16, PaceZone::HMP13) ]) ),


  WeekProgram.new(6, 
    Session.new([ Interval.time(15*60),
      Interval.distance(1.0), Recovery.distance(0.4), Interval.distance(2.0), Recovery.distance(0.4),
      Interval.distance(1.0), Recovery.distance(0.4), Interval.distance(1.0), Recovery.distance(0.4),
      Interval.time(10*60) ]),
    Session.new([ Interval.distance(1.5, PaceZone::EASY), Interval.distance(8, PaceZone::MT), Interval.distance(1.5, PaceZone::EASY) ]),
    Session.new([ Interval.distance(22, PaceZone::HMP19) ]) ),


  WeekProgram.new(5, 
    Session.new([ Interval.time(15*60),
      Repeat.new(3, [Interval.distance(1.6), Recovery.distance(0.4)]),
      Interval.time(10*60) ]),
    Session.new([ Interval.distance(8, PaceZone::EASY) ]),
    Session.new([ Interval.distance(16, PaceZone::HMP13) ]) ),


  WeekProgram.new(4, 
    Session.new([ Interval.time(15*60),
      Repeat.new(10, [Interval.distance(0.4), Recovery.distance(0.4)]),
      Interval.time(10*60) ]),
    Session.new([ Interval.distance(1.5, PaceZone::EASY), Interval.distance(8, PaceZone::MT), Interval.distance(1.5, PaceZone::EASY) ]),
    Session.new([ Interval.distance(25, PaceZone::HMP19) ]) ),

  WeekProgram.new(3, 
    Session.new([ Interval.time(15*60),
      Repeat.new(2, [Interval.distance(1.2), Recovery.time(120)]), Repeat.new(4, [Interval.distance(0.8), Recovery.time(120)]),
      Interval.time(10*60) ]),
    Session.new([ Interval.distance(1.5, PaceZone::EASY), Interval.distance(8, PaceZone::MT), Interval.distance(1.5, PaceZone::EASY) ]),
    Session.new([ Interval.distance(19, PaceZone::HMP13) ]) ),

  WeekProgram.new(2, 
    Session.new([ Interval.time(15*60),
      Repeat.new(5, [Interval.distance(1.0), Recovery.distance(0.4)]),
      Interval.time(10*60) ]),
    Session.new([ Interval.distance(3, PaceZone::EASY), Interval.distance(5, PaceZone::ST), Interval.distance(1.5, PaceZone::EASY) ]),
    Session.new([ Interval.distance(12.5, PaceZone::HMP13) ]) ),

  WeekProgram.new(1, 
    Session.new([ Interval.time(15*60),
      Repeat.new(6, [Interval.distance(0.4), Recovery.distance(0.4)]),
      Interval.time(10*60) ]),
    Session.new([ Interval.distance(5, PaceZone::EASY) ]),
    Session.new([ Interval.distance(21.1, PaceZone::HMP) ]) )
  ])
  
  NOVICE_MARATHON = TrainingPlan.new("Novice Marathon", [
  WeekProgram.new(16, 
    Session.new([ Interval.time(15*60),
      Repeat.new(3, [Interval.distance(1.6), Recovery.distance(0.4)]),
      Interval.time(10*60) ]),
    Session.new([ Interval.distance(3, PaceZone::EASY), Interval.distance(3, PaceZone::ST), Interval.distance(3, PaceZone::EASY) ]),
    Session.new([ Interval.distance(13, PaceZone::MP19) ]) ),
  
  WeekProgram.new(15, 
    Session.new([ Interval.time(15*60),
      Repeat.new(4, [Interval.distance(0.8), Recovery.time(120)]),
      Interval.time(10*60) ]),
    Session.new([ Interval.distance(1.5, PaceZone::EASY), Interval.distance(8, PaceZone::MT), Interval.distance(1.5, PaceZone::EASY) ]),
    Session.new([ Interval.distance(15, PaceZone::MP28) ]) ),
  
  WeekProgram.new(14, 
    Session.new([ Interval.time(15*60),
      Interval.distance(1.2), Recovery.distance(0.2),
      Interval.distance(1.0), Recovery.distance(0.2),
      Interval.distance(0.8), Recovery.distance(0.2),
      Interval.distance(0.6), Recovery.distance(0.2),
      Interval.distance(0.4), Recovery.distance(0.2),
      Interval.time(10*60) ]),
    Session.new([ Interval.distance(1.5, PaceZone::EASY), Interval.distance(8, PaceZone::LT), Interval.distance(1.5, PaceZone::EASY) ]),
    Session.new([ Interval.distance(16, PaceZone::MP28) ]) ),
  
  WeekProgram.new(13, 
    Session.new([ Interval.time(15*60), Repeat.new(5, [Interval.distance(1.0), Recovery.distance(0.4)]), Interval.time(10*60) ]),
    Session.new([ Interval.distance(1.5, PaceZone::EASY), Interval.distance(6.5, PaceZone::MT), Interval.distance(1.5, PaceZone::EASY) ]),
    Session.new([ Interval.distance(17, PaceZone::MP28) ]) ),
  
  WeekProgram.new(12, 
    Session.new([ Interval.time(15*60), Repeat.new(3, [Interval.distance(1.6), Recovery.time(60)]), Interval.time(10*60) ]),
    Session.new([ Interval.distance(3, PaceZone::EASY), Interval.distance(5, PaceZone::ST), Interval.distance(1.5, PaceZone::EASY) ]),
    Session.new([ Interval.distance(20, PaceZone::MP28) ]) ),
  
  WeekProgram.new(11, 
    Session.new([ Interval.time(15*60),
      Repeat.new(2, [Interval.distance(1.2), Recovery.time(120)]),
      Repeat.new(4, [Interval.distance(0.8), Recovery.time(120)]),
      Interval.time(10*60) ]),
    Session.new([ Interval.distance(1.5, PaceZone::EASY), Interval.distance(8, PaceZone::MT), Interval.distance(1.5, PaceZone::EASY) ]),
    Session.new([ Interval.distance(22, PaceZone::MP28) ]) ),
  
  WeekProgram.new(10, 
    Session.new([ Interval.time(15*60),
      Repeat.new(6, [Interval.distance(0.8), Recovery.time(90)]),
      Interval.time(10*60) ]),
    Session.new([ Interval.distance(1.5, PaceZone::EASY), Interval.distance(10, PaceZone::LT), Interval.distance(1.5, PaceZone::EASY) ]),
    Session.new([ Interval.distance(16, PaceZone::MP9) ]) ),
  
  WeekProgram.new(9, 
    Session.new([ Interval.time(15*60),
      Repeat.new(6, [Interval.distance(0.4), Recovery.time(90)]),
      Recovery.time(150),
      Repeat.new(6, [Interval.distance(0.4), Recovery.time(90)]), Interval.time(10*60) ]),
    Session.new([ Interval.distance(3, PaceZone::EASY), Interval.distance(5, PaceZone::ST), Interval.distance(1.5, PaceZone::EASY)  ]),
    Session.new([ Interval.distance(24, PaceZone::MP19) ]) ),

  WeekProgram.new(8, 
    Session.new([ Interval.time(15*60),
      Repeat.new(2, [Interval.distance(1.6), Recovery.time(60)]),
      Repeat.new(2, [Interval.distance(0.8), Recovery.time(60)]),
      Interval.time(10*60) ]),
    Session.new([ Interval.distance(1.5, PaceZone::EASY), Interval.distance(6.5, PaceZone::MT), Interval.distance(1.5, PaceZone::EASY) ]),
    Session.new([ Interval.distance(20, PaceZone::MP19) ]) ),

  WeekProgram.new(7, 
    Session.new([ Interval.time(15*60),
      Repeat.new(4, [Interval.distance(1.2), Recovery.time(120)]),
      Interval.time(10*60) ]),
    Session.new([ Interval.distance(16, PaceZone::MP) ]),
    Session.new([ Interval.distance(24, PaceZone::MP12) ]) ),

  WeekProgram.new(6, 
    Session.new([ Interval.time(15*60),
      Interval.distance(1.0), Recovery.distance(0.4), Interval.distance(2.0), Recovery.distance(0.4),
      Interval.distance(1.0), Recovery.distance(0.4), Interval.distance(1.0), Recovery.distance(0.4),
      Interval.time(10*60) ]),
    Session.new([ Interval.distance(1.5, PaceZone::EASY), Interval.distance(8, PaceZone::MP), Interval.distance(1.5, PaceZone::EASY) ]),
    Session.new([ Interval.distance(30, PaceZone::MP28) ]) ),

  WeekProgram.new(5, 
    Session.new([ Interval.time(15*60),
      Repeat.new(3, [Interval.distance(1.6), Recovery.distance(0.4)]),
      Interval.time(10*60) ]),
    Session.new([ Interval.distance(16, PaceZone::MP) ]),
    Session.new([ Interval.distance(21, PaceZone::MP9) ]) ),

  WeekProgram.new(4, 
    Session.new([ Interval.time(15*60),
      Repeat.new(10, [Interval.distance(0.4), Recovery.distance(0.4)]),
      Interval.time(10*60) ]),
    Session.new([ Interval.time(10*60), Interval.distance(13, PaceZone::MP), Interval.time(10*60) ]),
    Session.new([ Interval.distance(32, PaceZone::MP19) ]) ),

  WeekProgram.new(3, 
    Session.new([ Interval.time(15*60),
      Repeat.new(8, [Interval.distance(0.8), Recovery.time(90)]),
      Interval.time(10*60) ]),
    Session.new([ Interval.distance(1.5, PaceZone::EASY), Interval.distance(8, PaceZone::MT), Interval.distance(1.5, PaceZone::EASY) ]),
    Session.new([ Interval.distance(21, PaceZone::MP) ]) ),

  WeekProgram.new(2, 
    Session.new([ Interval.time(15*60),
      Repeat.new(5, [Interval.distance(1.0), Recovery.distance(0.4)]),
      Interval.time(10*60) ]),
    Session.new([ Interval.distance(3, PaceZone::EASY), Interval.distance(5, PaceZone::ST), Interval.distance(1.5, PaceZone::EASY) ]),
    Session.new([ Interval.distance(13, PaceZone::MP) ]) ),

  WeekProgram.new(1, 
    Session.new([ Interval.time(15*60),
      Repeat.new(6, [Interval.distance(0.4), Recovery.distance(0.4)]),
      Interval.time(10*60) ]),
    Session.new([ Interval.time(10*60), Interval.distance(5, PaceZone::MP), Interval.time(10*60) ]),
    Session.new([ Interval.distance(42.2, PaceZone::MP) ]) )
  ])
  
  MARATHON = TrainingPlan.new("Marathon", [])
end