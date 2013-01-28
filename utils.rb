module Utils
  # Format a number of seconds into mm:ss format. Easier for workout input/human
  def self.sec_to_mmss(seconds)
    mm = (seconds / 60).to_i
    ss = seconds.remainder(60).to_i
    "%d:%02d" % [mm, ss]
  end

  def self.format_pace(distance, type, paces)
    sec_to_mmss(get_pace(distance, type, paces))
  end


  def self.display_session(step, paces)
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
end