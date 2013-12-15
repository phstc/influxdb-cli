module InfluxDBClient
  class Client
    QUERY_LANGUAGE_MATCHER = /\A\s*((delete\s+from|select\s+.+\s+from)\s.+)\z/i
  end
end

