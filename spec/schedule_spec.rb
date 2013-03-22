require './schedule.rb'
# should be able to ask when the next occurance of that scheudle is, after a given date
# given ScheduleItems, should be able to find if a scheduleItem is already created for an occurance (and structure) 

# should handle if the options are invalid (crossing weekly, modifiers cross)

describe Schedule do
  describe "#convert_by_day" do
    before(:each) do
      @schedule = Schedule.new
    end

    it "takes an one day and returns a simple string" do
      days = ["Mo"]
      r = @schedule.convert_by_day(days)
      r.should eq('mo')
    end
    it "takes an multiple days and returns a simple string" do
      days = ["Mo","We"]
      r = @schedule.convert_by_day(days)
      r.should eq('mo,we')
    end
  end

  describe "#create" do
    it "takes simple hash of arguments" do
      params = {
        name: "Every other Monday",
        freq: "weekly",
        interval: "2",
        days_of_week: ["Mo"],
        duration: "1"
      }
      s = Schedule.new
      s.create(params)
      s.name.should eq("Every other Monday")
      s.freq.should eq(:weekly)
      s.interval.should eq(2)
      s.by_day.should eq('mo')
      s.duration.should eq(1) 
    end
  end

  describe "#valid?" do
    it "should be invalid if it is missing a name" do
      params = {
        freq: "weekly",
        interval: "1",
        days_of_week: ["Mo"],
        duration: "2"
      }
      s = Schedule.new
      s.create(params)
      s.valid?.should be_false
    end
    it "should be invalid if it is missing a freq" do
      params = {
        name: "Every Monday",
        interval: "1",
        days_of_week: ["Mo"],
        duration: "2"
      }
      s = Schedule.new
      s.create(params)
      s.valid?.should be_false
    end
    it "should be invalid if the duration is longer than the time between repetitions" do
      params = {
        name: "Every Monday",
        freq: "weekly",
        interval: "1",
        days_of_week: ["Mo"],
        duration: "8"
      }
      s = Schedule.new
      s.create(params)
      s.valid?.should be_false
    end
  end

  describe "#frequency_length" do
    it "returns 7 for weekly events" do
      params = {
        freq: "weekly",
        interval: "1",
      }
      s = Schedule.new
      s.create(params)
      s.frequency_length.should eq(7)
    end

    it "returns 14 for bi-weekly events" do
      params = {
        freq: "weekly",
        interval: "2",
      }
      s = Schedule.new
      s.create(params)
      s.frequency_length.should eq(14)
    end
  end

  describe "#next_date(start_date, after_date)" do
    before(:each) do
      params = {
        name: "Every other Monday",
        freq: "weekly",
        interval: "2",
        days_of_week: ["Mo"],
        duration: "1"
      }
      @s = Schedule.new
      @s.create(params)
    end

    it "returns next event if the start_date and after_date is before the first event" do
      # where the schedule originally starts (Sunday)
      start_date = Date.new(2013,3,10)
      # what it is expecting (first Monday after the 10th)
      first_instance = Date.new(2013,3,11)
      @s.next_date(start_date,start_date).should eq(first_instance)
    end

    it "returns date if it is the starting date" do
      # where to start the search (Monday)
      start_date = Date.new(2013,3,11)
      @s.next_date(start_date,start_date).should eq(start_date)
    end

    it "returns date if it is the next occurance" do
      # where to start the search (Monday)
      start_date = Date.new(2013,3,11)
      next_date = Date.new(2013,3,25)

      @s.next_date(start_date,next_date).should eq(next_date)
    end

  end

  describe "#first_date" do
    before(:each) do
      params = {
        name: "Every other Monday",
        freq: "weekly",
        interval: "2",
        days_of_week: ["Mo"],
        duration: "1"
      }
      @s = Schedule.new
      @s.create(params)
    end

    it "returns the first occurance of an event given a date" do
      # where to start the search (March 10th is a Sunday)
      start_date = Date.new(2013,3,10)
      # what it is expecting (first Monday after the 10th)
      first_instance = Date.new(2013,3,11)

      @s.first_date(start_date).should eq(first_instance)
    end

    it "returns the given date if it is a valid first occurance" do
      first_instance = Date.new(2013,3,11)

      @s.first_date(first_instance).should eq(first_instance)
    end

    it "returns the first occurance, even it if it the following week" do
      # Tuesday
      start_date = Date.new(2013,3,5)
      # the following Monday
      first_instance = Date.new(2013,3,11)

      @s.first_date(start_date).should eq(first_instance)
    end
  end

  describe "#translate_by_day" do
    it "converts simple days" do
      s = Schedule.new
      s.by_day = 'mo'
      s.translate_by_day.should eq([[1,1]])
    end
    it "converts simple days multiple days" do
      s = Schedule.new
      s.by_day = 'mo,we,fr'
      s.translate_by_day.should eq([[1,1],[1,3],[1,5]])
    end
    it "converts complex days" do
      s = Schedule.new
      s.by_day = '1mo,-2we' # no an option, but handles two cases
      s.translate_by_day.should eq([[1,1],[-2,3]])
    end
  end
end
