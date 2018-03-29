require 'json'

#--------------------Validating ruby syntax--------------------------
Dir.glob("/root/**/*.rb") do |ruby_file|
  puts "Checking syntax for: #{ruby_file}"
  status = system("ruby -c #{ruby_file} > /dev/null 2>&1")
  if "#{status}" == "false"
    puts "Ruby syntax not happy: #{ruby_file}"
    raise SyntaxError.new("Ruby syntax not happy: #{ruby_file}")
  end
end

#-------------------Validating json syntax---------------------------

#Dir.glob("/root/**/*.json") do |json_file|
#  puts "Checking syntax for: #{json_file}"
#  json = File.read("#{json_file}")
#  status = JSON.parse(json)
#  puts "#{status}"
#end
