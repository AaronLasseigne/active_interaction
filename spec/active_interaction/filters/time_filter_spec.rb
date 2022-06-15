require 'spec_helper'

describe ActiveInteraction::TimeFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  shared_context 'with format' do
    let(:format) { '%d/%m/%Y %H:%M:%S %z' }

    before do
      options[:format] = format
    end
  end

  describe '#initialize' do
    context 'with a format' do
      before { options[:format] = '%T' }

      context 'with a time zone' do
        before do
          time_with_zone = double

          time_zone = double
          allow(time_zone).to receive(:at).and_return(time_with_zone)

          allow(Time).to receive(:zone).and_return(time_zone)
        end

        it 'raises an error' do
          expect do
            filter
          end.to raise_error(ActiveInteraction::InvalidFilterError)
        end
      end
    end
  end

  describe '#process' do
    let(:result) { filter.process(value, nil) }

    context 'with a Time' do
      let(:value) { Time.new }

      it 'returns the Time' do
        expect(result.value).to eql value
      end
    end

    context 'with a String' do
      let(:value) { '2011-12-13 14:15:16 +1718' }

      it 'returns a Time' do
        expect(result.value).to eql Time.parse(value)
      end

      context 'with a time zone' do
        before do
          klass = double
          allow(klass).to receive(:parse).with(value).and_return(nil)

          allow(filter).to receive(:matches?).and_return(false)
          allow(filter).to receive(:klass).and_return(klass)
        end

        it 'indicates an error the string is not parsable' do
          error = result.errors.first

          expect(error).to be_an_instance_of ActiveInteraction::Filter::Error
          expect(error.type).to be :invalid_type
        end
      end

      context 'with format' do
        include_context 'with format'

        let(:value) { '13/12/2011 14:15:16 +1718' }

        it 'returns a Time' do
          expect(result.value).to eql Time.strptime(value, format)
        end
      end
    end

    context 'with an invalid String' do
      let(:value) { 'invalid' }

      it 'indicates an error' do
        error = result.errors.first

        expect(error).to be_an_instance_of ActiveInteraction::Filter::Error
        expect(error.type).to be :invalid_type
      end

      context 'with format' do
        include_context 'with format'

        it 'indicates an error' do
          error = result.errors.first

          expect(error).to be_an_instance_of ActiveInteraction::Filter::Error
          expect(error.type).to be :invalid_type
        end
      end
    end

    context 'with an implicit String' do
      let(:value) do
        Class.new do
          def to_str
            '2011-12-13 14:15:16 +1718'
          end
        end.new
      end

      it 'returns a Time' do
        expect(result.value).to eql Time.parse(value)
      end
    end

    context 'with a blank String' do
      let(:value) do
        Class.new do
          def to_str
            ' '
          end
        end.new
      end

      context 'optional' do
        include_context 'optional'

        it 'returns the default' do
          expect(result.value).to eql options[:default]
        end
      end

      context 'required' do
        include_context 'required'

        it 'indicates an error' do
          error = result.errors.first

          expect(error).to be_an_instance_of ActiveInteraction::Filter::Error
          expect(error.type).to be :missing
        end
      end
    end

    context 'with an Integer' do
      let(:value) { rand(1 << 16) }

      it 'returns the Time' do
        expect(result.value).to eql Time.at(value)
      end
    end

    context 'with an implicit Integer' do
      let(:value) do
        Class.new do
          def to_int
            @to_int ||= rand(1 << 16)
          end
        end.new
      end

      it 'returns the Time' do
        expect(result.value).to eql Time.at(value)
      end
    end

    context 'with a GroupedInput' do
      let(:year) { 2012 }
      let(:month) { 1 }
      let(:day) { 2 }
      let(:hour) { 3 }
      let(:min) { 4 }
      let(:sec) { 5 }
      let(:value) do
        ActiveInteraction::GroupedInput.new(
          '1' => year.to_s,
          '2' => month.to_s,
          '3' => day.to_s,
          '4' => hour.to_s,
          '5' => min.to_s,
          '6' => sec.to_s
        )
      end

      it 'returns a Time' do
        expect(
          result.value
        ).to eql Time.new(year, month, day, hour, min, sec)
      end
    end

    context 'with an invalid GroupedInput' do
      context 'empty' do
        let(:value) { ActiveInteraction::GroupedInput.new }

        it 'indicates an error' do
          error = result.errors.first

          expect(error).to be_an_instance_of ActiveInteraction::Filter::Error
          expect(error.type).to be :invalid_type
        end
      end

      context 'partial inputs' do
        let(:value) do
          ActiveInteraction::GroupedInput.new(
            '2' => '1'
          )
        end

        it 'indicates an error' do
          error = result.errors.first

          expect(error).to be_an_instance_of ActiveInteraction::Filter::Error
          expect(error.type).to be :invalid_type
        end
      end
    end
  end

  describe '#database_column_type' do
    it 'returns :datetime' do
      expect(filter.database_column_type).to be :datetime
    end
  end

  describe '#default' do
    context 'with a GroupedInput' do
      before do
        options[:default] = ActiveInteraction::GroupedInput.new(
          '1' => '2012',
          '2' => '1',
          '3' => '2',
          '4' => '3',
          '5' => '4',
          '6' => '5'
        )
      end

      it 'raises an error' do
        expect do
          filter.default(nil)
        end.to raise_error ActiveInteraction::InvalidDefaultError
      end
    end
  end
end
