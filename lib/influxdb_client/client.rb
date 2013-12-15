require 'terminal-table'

module InfluxDBClient
  class Client
    QUERY_LANGUAGE_MATCHER = /\A\s*((delete\s+from|select\s+.+\s+from)\s.+)\z/i

    def self.print_tabularize(result, output=$stdout)
      number_of_points = {}
      result.keys.each do |series|
        headings = result[series].first.keys
        rows = result[series].collect(&:values)
        table = Terminal::Table.new title: series, headings: headings, rows: rows
        output.puts table
        # empty line between time series output
        output.puts
        # count total per time series
        number_of_points["#{series}.count"] = result[series].size
      end
      number_of_points
    end
  end
end

