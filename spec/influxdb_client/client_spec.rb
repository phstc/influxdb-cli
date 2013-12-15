require 'spec_helper'

module InfluxDBClient
  describe Client do
    describe '.QUERY_LANGUAGE_MATCHER' do
      subject { Client::QUERY_LANGUAGE_MATCHER }
      context 'when SELECT queries' do
        it { should match('SELECT value1, value2 FROM response_times') }
        it { should match('select * from response_times') }
        it { should match('SELECT * FROM series1, series2') }
        it { should match('SELECT * FROM series1, series2 LIMIT 1') }

        it { should_not match('SELECT value1, value2FROM response_times') }
        it { should_not match('select from response_times') }
        it { should_not match('SELECT * FROM') }
      end

      context 'when DELETE queries' do
        it { should match('DELETE FROM response_times') }
        it { should match('delete from series1, series2') }

        it { should_not match('DELETEFROM response_times') }
        it { should_not match('delete value1, value2 from series1, series2') }
        it { should_not match('DELETE * FROM series1, series2') }
      end
    end
  end
end

