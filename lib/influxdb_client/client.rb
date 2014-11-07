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
    def self.print_tabularize(result, time_precision, output=$stdout)
      result ||= {}

      if result.keys.empty?
        output.puts 'No results found'
        return
      end

      result.keys.each do |series|
        result_series = result[series]
        if result_series.any?
          output.puts generate_table(series, result_series, time_precision)
          output.puts "#{result_series.size} " \
                      "#{pluralize(result_series.size, 'result')} " \
                      "found for #{series}"
        else
          output.puts "No results found for #{series}"
        end
        # print a line break between time series output
        output.puts
      end
    end

    def self.pretty=(pretty)
      @pretty = !!pretty
    end

    private

    def self.pluralize(count, singular, plural = nil)
      if count > 1
        plural ? plural : "#{singular}s"
      else
        singular
      end
    end

    def self.generate_table(series, result_series, time_precision)
      headings = result_series.first.keys
      precision_factor, str_format = case time_precision.to_s
      when 's'  then [1.0, '%F %T']
      when 'ms' then [1_000.0, '%F %T.%3N']
      when 'u'  then [1_000_000.0, '%F %T.%6N']
      else raise "unknown time_precision #{time_precision}"
      end
      rows = result_series.map do |row|
        if @pretty
          seconds_with_frac = row['time'].to_f / precision_factor
          row['time'] = Time.at(seconds_with_frac).utc.strftime(str_format)
        end
        row.values
      end

      Terminal::Table.new title: series, headings: headings, rows: rows
    end
  end
end
