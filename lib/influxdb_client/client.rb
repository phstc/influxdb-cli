require 'terminal-table'

module InfluxDBClient
  class Client
    QUERY_LANGUAGE_MATCHER  = /\A\s*((delete\s+from|select\s+.+\s+from)\s.+)\z/i
    SWITCH_DATABASE_MATCHER = /\A\s*use\s+(\S+)\s*\z/i

    # Prints a tabularized output from a query result.
    #
    # @param result [Hash] the {InfluDB::Client#query result}
    # @param output [STDOUT] the output to `puts` the results
    # @return [Hash] the number of points per time series i.e. { 'response_times.count' => 10 }
    def self.print_tabularize(result, output=$stdout)
      result ||= {}

      if result.keys.empty?
        output.puts 'No results found'
        return
      end

      result.keys.each do |series|
        result_series = result[series]
        if result_series.any?
          output.puts generate_table(series, result_series)
          output.puts "#{result_series.size} #{pluralize(result_series.size, 'result')} found for #{series}"
        else
          output.puts "No results found for #{series}"
        end
        # print a line break between time series output
        output.puts
      end
    end

    def self.pretty=(pretty)
      @pretty = pretty
    end

    private

    def self.pluralize(count, singular, plural = nil)
      if count > 1
        plural ? plural : "#{singular}s"
      else
        singular
      end
    end

    def self.generate_table(series, result_series)
      if @pretty
        result_series = result_series.map do |row|
          row["time"] = Time.at(row["time"]/1000)
          row
        end
      end

      headings = result_series.first.keys
      rows     = result_series.collect(&:values)

      Terminal::Table.new title: series, headings: headings, rows: rows
    end
  end
end

