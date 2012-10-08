training-plan
=============

Displays training plan for Half-Marathon using the FIRST training plan.

# What is it ?
The Furman FIRST training plan from [Furman University](http://www.furmanfirst.com/) is well described in 
Runner's World book [Run Less Run Faster](http://www.amazon.com/gp/product/159486649X/ref=as_li_ss_tl?ie=UTF8&camp=1789&creative=390957&creativeASIN=159486649X&linkCode=as2&tag=stephasthough-20).

Basically, it is a simple 16-week program with moderate running sessions that try to emphasize a 3+2 approach: 3 run sessions and 2 cross-training sessions. Each run session is called 'key run' and there are 3 different key runs:

* key run 1 - track repeats to improve economy, running speed and vo2 max
* key run 2 - tempo run paces to improve lactate tolerances
* key run 3 - long run paces to improve skeletal and cardiac muscle adaptation

# What problem does it solve ?
It can be a bit time-consuming to look in the charts and get an entire plan laid out, so
this small script is intended to be a starting point and get a quick overview of it.

# What's next ?

A couple of things can be done, time permitting:

* This needs some serious clean up
* Fix the workout to support pace zone (low/high) to match Garmin workout instead of single zone. Probably pace zone could be thought as 5K time +/- 30 seconds
* Support the 5K, 10K, half-marathon and marathon training programs
* Export workouts as TCX to be able to be imported in [Garmin Training Center](http://www.garmin.com/garmin/cms/intosports/training_center) assuming it can do so. It would be helpful if [Garmin Connect](http://connect.garmin.com/)
was supporting workout import too at some point. For now how to interact with both and the Garmin Agent is a bit in the nebulous side.

# How to run it
I'm still working on it and it's a bit 'look at the code', but the script is straightforward to use right now.

    ./plan.rb 

will just display the plan for a 24:00 5K reference time.