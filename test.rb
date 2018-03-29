def killPid(cmd)
   puts "I have entered the function"
   pid=exec("pidof #{cmd}")
   puts "#{pid}"
end

killPid('chef')
