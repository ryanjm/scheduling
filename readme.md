# Schedule

This project is primiarly focused on being able to endcode a repeating schedule and how to create new events. It is not concerned with marking them as complete or late.

### Want to be able to handle encoding the following formats:

* Due Monday, repeat every 2 weeks
* Start Monday due Friday, repeat every 2 weeks
* Due First Monday of the Month
* Start on First Monday, due Friday, repeat every month
* Due Monday, Wednesday, and Friday, repeat every 2 weeks 

### Form elements:

* Name
* Frequency
* Interval 
* Days of week (checkboxes)
* integer
* duration


## General todos:

* Be able to "search" schedule_items to see if any are coming up
* Ask schedule item to give all of the todos between two dates
* Ask schedule to give the next repeat after a given date giving it the start date
  * Need to handle multiple days (Mo, We, Fr)

## Various Processes

Obviously naming convention can be change, mostly I was trying to keep it short.

### Creating a schedule

The goal is to make this a simple form for the user to fill out and then for the `Schedule` class to setup the properties accordingly. See tests for example `params`.

### Creating a schedule_item

A schedule item is simply a join table between a `Schedule` and an `InspectionStructure`. Since a schedule can be something like "Every other Monday", when the user adds this `schedule_item` we could give them the option of when this schedule should start (vs starting when it is created). 

> Alternatively we could move this `start_date` to the `Schedule` itself. I don't like doing that since the user might be preping a new site and their contract doesn't start for another two weeks. OR the fact that this gives them the flexability to allow "Every other Monday" to represent two "different" schedules. One that starts on a given week and the other that starts on the next week. Either way, if we do want to refactor that, it shouldn't be hard to do so.

A `ScheduleItem` is responsibile for creating new todos.

### Creating schedule_todos

In order to create a `ScheduleTodo` we ask the `ScheduleItem` to give us all of the `ScheduleTodo`s for a given time frame. For example, for the month of March. `ScheduleItem` then loops through it's existing `ScheduleTodo`s (in Rails this would just be a database query) to see if any of them fall into the time frame.

If there is any, then we'll use the last date from those todos for the next part (we'll add one day to it). If there aren't any todos for that time frame, then we'll use the beginning of the requested time frame. We take that date and ask the `Schedule` for the next occurance of the event. In order to calculate that, it also needs to know the `start_date` from the `ScheduleItem`.

The `Schedule` is then responsible for returning the next date that satisfies the schedule _on or after_ that given date. This way if the user says "It starts next Monday" then that Monday can be included as the first todo. This date is then given back to the `ScheduleItem`. It will create a new `ScheduleTodo` and set the date as it's `start_date` and set the `end_date` as `start_date` plus the `Schedule`'s duration.

#### Calculating the next date

This is probably the most complicating part. There are two parts to it.

##### Finding the First Date

`Schedule` will use the `start_date` of `ScheduleItem` in order to figure out the first instance of that schedule. This will then be used to find all future instances. Based on the `freq` it will have to compare the date to what is closest matching date that satisfies the schedule. This logic is handled by the `#first_date` method.

##### Finding the next occurrence

The `#next_date` method will then use that first date to find the next. It will first look to see if there are any adjacent days matching (such as a schedule that is "Mo, We, Fr"). If there are not, then it will use the `#frequency_length` to find how many days away the next instance is. For example, given a schedule that is "Every other Monday" and we know our first date is a Monday, we just need to add 14 days to it to find the next occurrance of the schedule.

Since we are only concered about one date at a time, we can continually pass the date back through the `#next_date` method in order to find the next occurrence.

## Adding New Schedules

This has been my process for the tests to create in order to make a new schedule:

* Schedule#create - need to be able to pass in params in order to create a schedule
* Schedule#next_occurrence - define the first / subsequent occurances
* Schedule#next_date - the basis for figuring out the next date

