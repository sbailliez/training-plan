training-plan
=============

Displays training plan for 5K, 10K, Half-Marathon, Novice Marathon and Marathon using the FIRST training plan.

# What is it ?
The Furman FIRST training plan from [Furman University](http://www.furmanfirst.com/) is well described in 
Runner's World book [Run Less Run Faster](http://www.amazon.com/gp/product/159486649X/ref=as_li_ss_tl?ie=UTF8&camp=1789&creative=390957&creativeASIN=159486649X&linkCode=as2&tag=stephasthough-20).

Basically, it is a simple 12 or 16-week program with moderate running sessions that try to emphasize a 3+2 approach: 3 run sessions and 2 cross-training sessions. Each run session is called 'key run' and there are 3 different key runs:

* key run 1 - track repeats to improve economy, running speed and vo2 max
* key run 2 - tempo run paces to improve lactate tolerances
* key run 3 - long run paces to improve skeletal and cardiac muscle adaptation

The 12-week program is for the 5K and 10K while the 16-week program is for the half-marathon and marathon.

# What problem does it solve ?
It can be a bit time-consuming to look in the charts and get an entire plan laid out, so
this small script is intended to be a starting point and get a quick overview of it.

FURMAN provides a calculator online, but this is all but convenient for an entire plan (moreover it is only in miles), so the script will do the entire plan and gives you the paces to run each key-run once you have your 5K reference time.

# What's next ?

A couple of things can be done, time permitting:

* This needs some serious clean up
* Fix the workout to support pace zone (low/high) to match Garmin workout instead of single zone. Probably pace zone could be thought as 5K time +/- 30 seconds
* Export workouts as TCX to be able to be imported in [Garmin Training Center](http://www.garmin.com/garmin/cms/intosports/training_center) assuming it can do so. It would be helpful if [Garmin Connect](http://connect.garmin.com/)
was supporting workout import too at some point. For now how to interact with both and the Garmin Agent is a bit in the nebulous side.

# How to run it
I'm still working on it and it's a bit 'look at the code', but the script is straightforward to use right now.

    ./plan.rb --time 22:40 --program half-marathon

will just display the half-marathon plan for a 22:40 5K reference time.

# Why is this in metrics and not in miles ?
Speed intervals are expressed in metrics, in particular because their reference is obviously based on the distance of a race track which is 400m, so it makes practically little sense to express a workout plan in a mix bag of metrics and miles with a mile pace, so metrics is used everywhere. A running watch such as [Garmin Forerunner](https://buy.garmin.com/shop/shop.do?cID=142&ra=true) or even iPhone applications such as [Runkeeper](http://www.runkeeper.com/) can be set to display in metrics or miles.

# What is the output like ?
For now, it will just output something like:

    Training Program for Half-Marathon with a 22:40 5K time
    Week 16
      KR1
        Interval: 15min @ 5:41
        12 x (Interval: 0.4km @ 4:07 - RI 0.4km)
        Interval: 10min @ 5:41
      KR2
        Interval: 3.0km @ 5:41
        Interval: 5.0km @ 4:42
        Interval: 1.5km @ 5:41
      KR3
        Interval: 12.5km @ 5:11

    Week 15
      KR1
        Interval: 15min @ 5:41
        Interval: 0.4km @ 4:07
        RI 0.4km
        Interval: 0.6km @ 4:11
        RI 0.4km
        Interval: 0.8km @ 4:13
        RI 0.4km
        Interval: 1.2km @ 4:17
        RI 0.4km
        Interval: 0.8km @ 4:13
        RI 0.4km
        Interval: 0.6km @ 4:11
        RI 0.4km
        Interval: 0.4km @ 4:07
        RI 0.4km
        Interval: 10min @ 5:41
      KR2
        Interval: 3.0km @ 5:41
        Interval: 5.0km @ 4:52
        Interval: 1.5km @ 5:41
      KR3
        Interval: 12.5km @ 5:11

    Week 14
      KR1
        Interval: 15min @ 5:41
        6 x (Interval: 0.8km @ 4:13 - RI 90s)
        Interval: 10min @ 5:41
      KR2
        Interval: 3.0km @ 5:41
        Interval: 5.0km @ 4:42
        Interval: 1.5km @ 5:41
      KR3
        Interval: 16.0km @ 5:41

    Week 13
      KR1
        Interval: 15min @ 5:41
        5 x (Interval: 1.0km @ 4:14 - RI 0.4km)
        Interval: 10min @ 5:41
      KR2
        Interval: 3.0km @ 5:41
        Interval: 5.0km @ 4:42
        Interval: 1.5km @ 5:41
      KR3
        Interval: 14.0km @ 5:11

    Week 12
      KR1
        Interval: 15min @ 5:41
        3 x (Interval: 1.6km @ 4:23 - RI 60s)
        Interval: 10min @ 5:41
      KR2
        Interval: 1.5km @ 5:41
        Interval: 10.0km @ 5:01
        Interval: 1.5km @ 5:41
      KR3
        Interval: 18.0km @ 5:17

    Week 11
      KR1
        Interval: 15min @ 5:41
        2 x (Interval: 1.2km @ 4:17 - RI 120s)
        4 x (Interval: 0.8km @ 4:13 - RI 120s)
        Interval: 10min @ 5:41
      KR2
        Interval: 1.5km @ 5:41
        Interval: 3.0km @ 4:52
        Interval: 1.5km @ 5:41
        Interval: 3.0km @ 4:52
        Interval: 1.5km @ 5:41
      KR3
        Interval: 16.0km @ 5:11

    Week 10
      KR1
        Interval: 15min @ 5:41
        6 x (Interval: 0.8km @ 4:13 - RI 90s)
        Interval: 10min @ 5:41
      KR2
        Interval: 1.5km @ 5:41
        Interval: 8.0km @ 4:52
        Interval: 1.5km @ 5:41
      KR3
        Interval: 19.0km @ 5:17

    Week 9
      KR1
        Interval: 15min @ 5:41
        6 x (Interval: 0.4km @ 4:07 - RI 90s)
        RI 150s
        6 x (Interval: 0.4km @ 4:07 - RI 90s)
        Interval: 10min @ 5:41
      KR2
        Interval: 1.5km @ 5:41
        Interval: 3.0km @ 4:52
        Interval: 1.5km @ 5:41
        Interval: 3.0km @ 4:52
        Interval: 1.5km @ 5:41
      KR3
        Interval: 12.5km @ 5:11

    Week 8
      KR1
        Interval: 15min @ 5:41
        2 x (Interval: 1.6km @ 4:23 - RI 60s)
        2 x (Interval: 0.8km @ 4:13 - RI 60s)
        Interval: 10min @ 5:41
      KR2
        Interval: 1.5km @ 5:41
        Interval: 8.0km @ 4:52
        Interval: 1.5km @ 5:41
      KR3
        Interval: 21.0km @ 5:11

    Week 7
      KR1
        Interval: 15min @ 5:41
        4 x (Interval: 1.2km @ 4:17 - RI 120s)
        Interval: 10min @ 5:41
      KR2
        Interval: 1.5km @ 5:41
        Interval: 10.0km @ 4:52
        Interval: 1.5km @ 5:41
      KR3
        Interval: 16.0km @ 5:11

    Week 6
      KR1
        Interval: 15min @ 5:41
        Interval: 1.0km @ 4:14
        RI 0.4km
        Interval: 2.0km @ 4:25
        RI 0.4km
        Interval: 1.0km @ 4:14
        RI 0.4km
        Interval: 1.0km @ 4:14
        RI 0.4km
        Interval: 10min @ 5:41
      KR2
        Interval: 1.5km @ 5:41
        Interval: 8.0km @ 4:52
        Interval: 1.5km @ 5:41
      KR3
        Interval: 22.0km @ 5:17

    Week 5
      KR1
        Interval: 15min @ 5:41
        3 x (Interval: 1.6km @ 4:23 - RI 0.4km)
        Interval: 10min @ 5:41
      KR2
        Interval: 8.0km @ 5:41
      KR3
        Interval: 16.0km @ 5:11

    Week 4
      KR1
        Interval: 15min @ 5:41
        10 x (Interval: 0.4km @ 4:07 - RI 0.4km)
        Interval: 10min @ 5:41
      KR2
        Interval: 1.5km @ 5:41
        Interval: 8.0km @ 4:52
        Interval: 1.5km @ 5:41
      KR3
        Interval: 25.0km @ 5:17

    Week 3
      KR1
        Interval: 15min @ 5:41
        2 x (Interval: 1.2km @ 4:17 - RI 120s)
        4 x (Interval: 0.8km @ 4:13 - RI 120s)
        Interval: 10min @ 5:41
      KR2
        Interval: 1.5km @ 5:41
        Interval: 8.0km @ 4:52
        Interval: 1.5km @ 5:41
      KR3
        Interval: 19.0km @ 5:11

    Week 2
      KR1
        Interval: 15min @ 5:41
        5 x (Interval: 1.0km @ 4:14 - RI 0.4km)
        Interval: 10min @ 5:41
      KR2
        Interval: 3.0km @ 5:41
        Interval: 5.0km @ 4:42
        Interval: 1.5km @ 5:41
      KR3
        Interval: 12.5km @ 5:11

    Week 1
      KR1
        Interval: 15min @ 5:41
        6 x (Interval: 0.4km @ 4:07 - RI 0.4km)
        Interval: 10min @ 5:41
      KR2
        Interval: 5.0km @ 5:41
      KR3
        Interval: 21.1km @ 4:58