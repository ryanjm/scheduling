require './schedule_todo.rb'
require './schedule.rb'

# This would relate a given schedule to a inspection_strucutre object. For now I'm going to leave it off, except to create a unique ID for it.

class ScheduleItem

  attr_accessor :id
  attr_accessor :start_date # when this should go into effect
  attr_accessor :inspection_structure_id
  attr_accessor :schedule
  attr_accessor :schedule_todos # hasMany :todos
  
  def initialize
    @id = rand(100)
    @inspection_structure_id = rand(100)
    @schedule_todos = []
  end

  # Creates todos for this schedule between the given dates
  # It shouldn't create an additional todos.
  # returns the todos that are between the dates
  # TODO: remove inspection_structure_id. It is here just for tests.
  def todos(beginning_date, ending_date, inspection_structure_id)
    # create an array to hold the todos
    new_todos = []

    # TODO: loop through existing todos to see if there are any matches

    # grab latest date (either todo or start_date)
    start = beginning_date

    # while the start is not created thatn the end_date
    while start <= ending_date do
      # grab the next occurance
      next_date = @schedule.next_date(start,start_date)
      puts "next_date = #{next_date}"
      if (next_date <= ending_date)
        
        todo = ScheduleTodo.new
        todo.inspection_structure_id = inspection_structure_id
        todo.schedule_item = self
        todo.start_date = next_date
        todo.end_date = next_date + @schedule.duration
        
        # add it to the list to be returned
        new_todos << todo
        # add it to the hasMany list for future checking
        @schedule_todos << todo
      end
      start = next_date
    end

    new_todos
  end

  
end
