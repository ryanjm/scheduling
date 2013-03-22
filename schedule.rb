# Encoding is heavely based off of ICS format
# http://www.ietf.org/rfc/rfc2445.txt
# 4.3.10 Recurrence Rule
# It is HIGHLY suggested to read through the entire section before reading this code. By sticking closely to the ICS format, we should be able to easily expand out the options if we want to handle more cases.
#
# duration - ics assumes start/end dates to figure out how long an event should be and how to repeat it. I'm changing it a little by having a duration in days. My approach is for the schedule to define when something is DUE, and then duration should be how many days the inspector has to do it. I think the due date is more important then when it should be started.
#
# TODO: figure out the form elements that the user will use
# TODO: have a `create` method to use that user hash (as if from a form) to populate fields
 
class Schedule

  attr_accessor :id
  attr_accessor :name
  attr_accessor :freq # identifies type of recurrance (required)
  attr_accessor :interval # how often to repeat (positive value, default = 1)
  attr_accessor :by_day # list of days, with possible value in front
  attr_accessor :by_month_day # integer representing day in month
  attr_accessor :by_week_no # integer representing week in year
  attr_accessor :by_month # integer representing mo in year
  attr_accessor :wkst # defines when the week starts (defaults to Monday)
  attr_accessor :duration # breaking from ics a little here (see above)

  def initialize
    @interval = 1
    @wkst = :mo
    @id = rand(100)
  end

  FREQ = [:daily, :weekly, :monthly]
  DAYS = [:su, :mo, :tu, :we, :th, :fr, :sa]

  def convert_by_day(days_of_week)
    selected_days = days_of_week.map do |day|
      d = day.downcase.to_sym
      DAYS.include?(d) ? d.to_s : nil
    end
    selected_days.compact.join(",")
  end

  def create(params)
    @name = params[:name] if params[:name]

    if (params[:freq] && FREQ.include?(params[:freq].to_sym))
      @freq = params[:freq].to_sym
    end

    @interval = params[:interval].to_i if params[:interval]

    @by_day = convert_by_day(params[:days_of_week]) if params[:days_of_week]

    @duration = params[:duration].to_i if params[:duration]
  end
  
  def valid?
    if @name.nil? || @freq.nil?
      false
    elsif frequency_length < @duration
      false
    else
      true
    end
  end

  # TODO: needs to know the month it is looking at
  def frequency_length
    if @freq == :daily
      @interval * 1
    elsif @freq == :weekly
      @interval * 7
    elsif @frequency == :monthly
      @interval * 29 # TODO: this number needs to be more accurate
    end
  end

  # Converts @by_day to an nested array
  # The first part is the offset (default = 1) and second is wday number
  # offset would be used for things like "second Monday of the month" ([2,1])
  # 'mo' => [[1,1]]
  # 'mo,we,fr' => [[1,1],[1,3],[1,5]]
  def translate_by_day
    days = @by_day.split(',')
    days.map do |day|
      if day.length == 2
        [ 1, DAYS.index(day.to_sym)]
      elsif day.length == 3
        [ day[0].to_i, DAYS.index(day[1..-1].to_sym) ]
      else
        [ day[0..-3].to_i, DAYS.index(day[-2..-1].to_sym) ]
      end
    end
  end

  # Will return the _first_ time this event should happen
  # Does not take into account the interval
  def first_date(start_date)
    if @freq == :weekly
      wday = start_date.wday
      days = translate_by_day # i.e. [[1,1]] - 
      # we want the first occurance where wday <= given day
      # example: schedule is [:mo,:we,:fr]
      # days = [[1,1],[1,3],[1,5]]
      # if our start_date is Sunday (wday=0), we want to stop on Monday (0 <= 1)
      # if our start_date is Tuesday (wday=2), we want to stop on Wednesday ( 2 <= 3)
      # if our start_date is Saturday (wday=6), we want the following Monday
      # TODO: handle the case that start_date is Saturday and we need to go to the next week
      day_index = days.index { |day| wday <= day[1] }
      # if it is nil, we want the earliest day of the week
      if day_index.nil?
        # I'd like to assume they are in order, but is that guaranteed?
        first_day = days.sort {|x,y| x[1] <=> y[1] }.first
        day_index = days.index(first_day)
        # We then need to bump up the start_date a week
        start_date+=7
      end
      # day will be the wday of the first matching date
      day = days[day_index][1]
      # we want to return the start_date plus the number of days till the firt match
      start_date + (day - wday)
    end
  end

  # Will return the next due date for the given schedule
  # Takes into account the frequency and then asks first_date for new date date
  def next_date(start_date,after_date)
    # TODO: needs to actually account for the day of the week it _should_ be on.
  
    # Frist time the event happened
    first_occurrence =  first_date(start_date)
    # Offset to add to the first_occurrence
    period = 0

    # period = days between repeated events
    if @freq == :weekly
      period = 7.0 * self.interval
    else
      nil
    end

    # diff = days between our `after_date` and the `first_occurrence`
    diff = after_date - first_occurrence
    diff = 0 if diff < 0
    # ( diff / period ) - we want to find how many `period`s happened during that `diff`
    # _.floor - we want to round down
    # _ * period - multiply by that period to get the right offset
    # _ = days on or after which our next occurance is
    days_after = ( diff / period ).floor * period
    
    first_date( first_occurrence + days_after )
  end
  # be able to grab the next x occurances after a given time
end
