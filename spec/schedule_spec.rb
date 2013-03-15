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

  describe "#next_date" do
    it "returns next event after a given date" do
      params = {
        name: "Every other Monday",
        freq: "weekly",
        interval: "2",
        days_of_week: ["Mo"],
        duration: "1"
      }
      s = Schedule.new
      s.create(params)

      # where to start the search
      start_date = Date.new(2013,1,10)
      # what it is expecting (first Monday after the 10th)
      first_instance = Date.new(2013,1,11)
      s.next_date(start_date,start_date).should eq(first_instance)
    end
  end

  describe "#first_date" do
    it "returns the first occurance of an event given a date" do
      params = {
        name: "Every other Monday",
        freq: "weekly",
        interval: "2",
        days_of_week: ["Mo"],
        duration: "1"
      }
      s = Schedule.new
      s.create(params)

      # where to start the search (March 10th is a Sunday)
      start_date = Date.new(2013,3,10)
      # what it is expecting (first Monday after the 10th)
      first_instance = Date.new(2013,3,11)

      s.first_date(start_date).should eq(first_instance)

    end
  end

  describe "#translate_by_day" do
    it "converts simple days" do
      s = Schedule.new
      s.by_day = 'mo'
      s.translate_by_day.should eq([[1,:mo]])
    end
  end
end
