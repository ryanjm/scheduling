require './schedule.rb'
require './schedule_item.rb'
require 'date'

describe ScheduleItem do
  # create
  # ask it to create todos between two dates
  describe "#todos" do
    before(:each) do
      params = {
        name: "Every other Monday",
        freq: "weekly",
        interval: "2",
        days_of_week: ["Mo"],
        duration: "1"
      }
      @schedule = Schedule.new
      @schedule.create(params)
      @schedule_item = ScheduleItem.new
      @schedule_item.schedule = @schedule
      # beginning of March 2013
      @schedule_item.start_date = Date.new(2013,3,1)
    end

    it "creates todos between two dates" do
      start_date = Date.new(2013,3,2)
      end_date = Date.new(2013,3,28)

      todos = @schedule_item.todos(start_date,end_date,2)

      expect1 = Date.new(2013,3,4)
      expect2 = Date.new(2013,3,18)

      todos.length.should eq(2)
      todos[0].end_date.should eq(expect1)
      todos[1].end_date.should eq(expect2)
    end

    it "doesn't duplicate todos" do
      
    end
  end
end
