# A sample Guardfile
# More info at https://github.com/guard/guard#readme

# cli: '--tag wip'
guard 'rspec', cli: '-c' do
  # watch(%r{^spec/.+_spec\\.rb$})
  watch(%r{^spec/.+_spec.rb$})
  # watch('schedule.rb')
  # watch('schedule_item.rb')
  # watch('schedule_todo.rb')
  watch(%r{^(.+).rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  # watch('spec/spec_helper.rb')  { "spec" }
end

