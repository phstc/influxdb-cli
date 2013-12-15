require 'terminal-table'

module InfluxDBClient
  class Client
    QUERY_LANGUAGE_MATCHER = /\A\s*((delete\s+from|select\s+.+\s+from)\s.+)\z/i

    # Prints a tabularized output from a query result.
    #
    # @param result [Hash] the {InfluDB::Client#query result}
    # @param output [STDOUT] the output to `puts` the results
    # @return [Hash] the number of points per time series i.e. { 'response_times.count' => 10 }
    def self.print_tabularize(result, output=$stdout)
      number_of_points = {}
      result.keys.each do |series|
        if result[series].any?
          output.puts generate_table(series, result)
        else
          output.puts "No results found for #{series}"
        end
        # empty line between time series output
        output.puts
        # count total per time series
        number_of_points["#{series}.count"] = result[series].size
      end
      number_of_points
    end

    private

    def self.generate_table(series, result)
      headings = result[series].first.keys
      rows = result[series].collect(&:values)

      Terminal::Table.new title: series, headings: headings, rows: rows
    end
  end
end

