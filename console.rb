require 'date'
require './schedule.rb'

params = {
  name: "Every other Monday",
  freq: "weekly",
  interval: "2",
  days_of_week: ["Mo"],
  duration: "1"
}
@s = Schedule.new
@s.create(params)

