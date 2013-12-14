InfluxDB-CLI
============

Ruby CLI for InfluxDB is a simple Ruby console (empowered with [Pry](https://github.com/pry/pry)) connected to an InfluxDB server with supplied parameters. In order to connect to InfluxDB, it uses [influxdb-ruby](https://github.com/influxdb/influxdb-ruby), so you can access any avaiable method from influxdb-ruby in the console through the `db` variable i.e.: `db.write_point(name, data)`, `db.query('SELECT value FROM response_times')` etc.


### Installation
```shell
gem install influxdb-cli
```

### Options

```shell
Usage:
  influxdb-cli

Options:
  -h, [--host=HOST]          # Hostname
                             # Default: localhost
      [--port=PORT]          # Port
                             # Default: 8086
  -u, [--username=USERNAME]  # Username
                             # Default: root
  -p, [--password=PASSWORD]  # Password
                             # Default: root
  -d, [--database=DATABASE]  # Database
                             # Default: db
```

### Usage

```shell
influxdb-cli
Connecting to {"host"=>"localhost", "port"=>8086, "username"=>"root", "password"=>"root", "database"=>"db"}
✔ ready
2.0.0 (main)> db.query('SELECT * FROM deploys')
=> {
     "deploys" => [
        [ 0] {
                         "time" => "...",
              "sequence_number" => "...",
                  "application" => "...",
                       "branch" => "...",
              "latest_revision" => "...",
            "previous_revision" => "...",
                        "stage" => "..."
        },
2.0.0 (main)> db.get_database_list
```
[Tabularize?](https://github.com/phstc/influxdb-cli/issues/1)

### Pry commands

As influxdb-cli is empowered with Pry, all Pry awesome commands are avaiable in the console.

```shell
2.0.0 (main)> show-source InfluxDB::Client#query

From: /Users/pablo/.gem/ruby/2.0.0/gems/influxdb-0.0.11/lib/influxdb/client.rb @ line 152:
Owner: InfluxDB::Client
Visibility: public
Number of lines: 17

def query(query)
  url = full_url("db/#{@database}/series", "q=#{query}")
  url = URI.encode url
  response = @http.request(Net::HTTP::Get.new(url))
  series = JSON.parse(response.body)

  if block_given?
    series.each { |s| yield s['name'], denormalize_series(s) }
  else
    series.reduce({}) do |col, s|
      name                  = s['name']
      denormalized_series   = denormalize_series s
      col[name]             = denormalized_series
      col
    end
  end
end

2.0.0 (main)> show-doc InfluxDB::Client#initialize

From: /Users/pablo/.gem/ruby/2.0.0/gems/influxdb-0.0.11/lib/influxdb/client.rb @ line 13:
Owner: InfluxDB::Client
Visibility: private
Signature: initialize(*args)
Number of lines: 20

Initializes a new Influxdb client

=== Examples:

    Influxdb.new                               # connect to localhost using root/root
                                               # as the credentials and doesn't connect to a db

    Influxdb.new 'db'                          # connect to localhost using root/root
                                               # as the credentials and 'db' as the db name

    Influxdb.new :username => 'username'       # override username, other defaults remain unchanged

    Influxdb.new 'db', :username => 'username' # override username, use 'db' as the db name

=== Valid options in hash

+:hostname+:: the hostname to connect to
+:port+:: the port to connect to
+:username+:: the username to use when executing commands
+:password+:: the password associated with the username
```

