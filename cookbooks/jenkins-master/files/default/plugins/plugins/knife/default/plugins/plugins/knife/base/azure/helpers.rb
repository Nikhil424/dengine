module Azure
  module Helpers

    def random_string(len=10)
      (0...len).map{65.+(rand(25)).chr}.join
    end

    def strip_non_ascii(string)
      string.gsub(/[^0-9a-z ]/i, '')
    end

    def display_list(ui=nil, columns=[], rows=[])
      columns = columns.map{ |col| ui.color(col, :bold) }
      count = columns.count
      rows = columns.concat(rows)
      puts ''
      puts ui.list(rows, :uneven_columns_across, count)
    end

    def msg_pair(ui=nil, label=nil, value=nil, color=:cyan)
      if value && !value.to_s.empty?
        puts "#{ui.color(label, color)}: #{value}"
      end
    end
  end
end
