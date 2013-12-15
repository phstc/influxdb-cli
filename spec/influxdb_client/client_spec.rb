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

    describe '.print_tabularize' do
      let(:result)  { { series1: [{ value1: 1, value2: 2 }],
                        series2: [{ value3: 3,   value4: 4, value5: nil, value6: nil },
                                  { value3: nil, value4: 4, value5: 5,   value6: 6   }] } }

      it 'returns series count' do
        expect(described_class.print_tabularize(result)).to eq({ 'series1.count' => 1, 'series2.count' => 2 })
      end

      it 'generates tables' do
        expect(Terminal::Table).to receive(:new).
          with(title: :series1, headings: [:value1, :value2], rows: [[1, 2]])

        expect(Terminal::Table).to receive(:new).
          with(title: :series2, headings: [:value3, :value4, :value5, :value6], rows: [[3, 4, nil, nil], [nil, 4, 5, 6]])

        described_class.print_tabularize(result)
      end

      it 'puts tables' do
        output = double 'Output'
        table  = double 'Table'
        Terminal::Table.stub(new: table)

        # should print series1 and series2
        expect(output).to receive(:puts).twice.with(table)
        # line break for series
        expect(output).to receive(:puts).twice.with(no_args)

        described_class.print_tabularize(result, output)
      end
    end
  end
end

