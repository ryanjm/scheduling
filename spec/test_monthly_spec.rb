require './spec/spec_helper.rb'

#      March 2013
# Su Mo Tu We Th Fr Sa
#                 1  2
#  3  4  5  6  7  8  9
# 10 11 12 13 14 15 16
# 17 18 19 20 21 22 23
# 24 25 26 27 28 29 30
# 31
#      April 2013
# Su Mo Tu We Th Fr Sa
#     1  2  3  4  5  6
#  7  8  9 10 11 12 13
# 14 15 16 17 18 19 20
# 21 22 23 24 25 26 27
# 28 29 30

describe "Monthly Schedules" do
  context "Monthly" do
    it "should handle first Monday of the month" do
      test_schedule({
        freq: 'monthly',
        interval: '1',
        days_of_month: ['1','Mo'],
        duration: '0'
      },{
        start_schedule: Date.new(2013,3,1),
        start_search: Date.new(2013,3,5),
        end_search: Date.new(2013,3,25)
      },{
        start_dates: [[3,11],[3,18],[3,25]],
        end_dates: [[3,11],[3,18],[3,25]],
      })
    end
  end
end
