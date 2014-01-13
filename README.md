InfluxDB-CLI
============

Ruby CLI for InfluxDB is a simple Ruby console (empowered with [Pry](https://github.com/pry/pry)) connected to an InfluxDB server using given parameters. In order to connect to InfluxDB, it uses [influxdb-ruby](https://github.com/influxdb/influxdb-ruby), so you can access any avaiable method from influxdb-ruby in the console through the `db` variable i.e.: `db.write_point(name, data)`, `db.query('SELECT value FROM response_times')` etc.

[![Build Status](https://secure.travis-ci.org/phstc/influxdb-cli.png)](http://travis-ci.org/phstc/influxdb-cli)

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

#### Connect to a database

```shell
$ influxdb-cli
Connecting to {"host"=>"localhost", "port"=>8086, "username"=>"root", "password"=>"root", "database"=>"db"}
✔ ready
```

or

```shell
$ influxdb-cli -u user -p password -d database -h sandbox.influxdb.org --port 9061
Connecting to {"host"=>"sandbox.influxdb.org", "port"=>"9061", "username"=>"username", "password"=>"password", "database"=>"database"}
✔ ready
```

[InfluxDB Playground](http://play.influxdb.org) :metal:

#### Create a database and user

```ruby
2.0.0 (main)> db.create_database 'db'
2.0.0 (main)> db.create_database_user 'db', 'root', 'root'
```

#### List databases

```ruby
2.0.0 (main)> db.get_database_list
```

#### Switch databases

```ruby
2.0.0 (main)> use other_database
2.0.0 (main)> db.database
=> "other_database"
```

#### Write a point

```ruby
2.0.0 (main)> db.write_point('tests', { message: 'Hello Pablo' })

2.0.0 (main)> SELECT * FROM tests

+---------------+-----------------+-------------+
|                     tests                     |
+---------------+-----------------+-------------+
| time          | sequence_number | message     |
+---------------+-----------------+-------------+
| 1387287723816 | 1               | Hello Pablo |
+---------------+-----------------+-------------+
1 result found for tests

Query duration: 0.0s
```

#### Return the last point from every time series in the database

```ruby
2.0.0 (main)> SELECT * FROM /.*/ LIMIT 1
```

or to get only the name from every time series in the database.

```ruby
2.0.0 (main)> db.query('SELECT * FROM /.*/ LIMIT 1').keys
=> [
    [0] "tests",
    [1] "response_times",
    [2] "deploys",
    [3] "..."
]
```


#### Query with a [tabularized output](https://github.com/visionmedia/terminal-table)

```ruby
2.0.0 (main)> SELECT * FROM deploys
+---------------+-----------------+-----------------+--------+-----------------+-------------------+----------+
|                                                    deploys                                                  |
+---------------+-----------------+-----------------+--------+-----------------+-------------------+----------+
| time          | sequence_number | application     | branch | latest_revision | previous_revision | stage    |
+---------------+-----------------+-----------------+--------+-----------------+-------------------+----------+
| ...           | ...             | ...             | ...    | ...             | ...               | ...      |
+---------------+-----------------+-----------------+--------+-----------------+-------------------+----------+

1 result found for deploys

Query duration: 0.49s
```

#### Query with a [Ruby Hash output](https://github.com/michaeldv/awesome_print)

```ruby
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
```

#### Other methods

```ruby
2.0.0 (main)> db.write_point(name, data)
2.0.0 (main)> db.get_database_list
2.0.0 (main)> ls -q db
InfluxDB::Client#methods:
  _write                    create_database       database=             delete_database_user    get_database_user_list  password   port=  queue=                username
  alter_database_privilege  create_database_user  delete_cluster_admin  get_cluster_admin_list  host                    password=  query  update_cluster_admin  username=
  create_cluster_admin      database              delete_database       get_database_list       host=                   port       queue  update_database_user  write_point
instance variables: @database  @host  @http  @password  @port  @queue  @username
```

### Pry commands

As influxdb-cli is empowered with Pry, all Pry awesome commands are avaiable in the console.

#### show-source

```ruby
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
```

#### show-doc

```ruby

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

