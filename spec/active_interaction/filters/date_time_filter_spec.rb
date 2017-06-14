require 'spec_helper'

describe ActiveInteraction::DateTimeFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  shared_context 'with format' do
    let(:format) { '%d/%m/%Y %H:%M:%S %:z' }

    before do
      options[:format] = format
    end
  end

  describe '#cast' do
    let(:result) { filter.cast(value, nil) }

    context 'with a Datetime' do
      let(:value) { DateTime.new }

      it 'returns the DateTime' do
        expect(result).to eql value
      end
    end

    context 'with a String' do
      let(:value) { '2011-12-13T14:15:16+17:18' }

      it 'returns a DateTime' do
        expect(result).to eql DateTime.parse(value)
      end

      context 'with format' do
        include_context 'with format'

        let(:value) { '13/12/2011 14:15:16 +17:18' }

        it 'returns a DateTime' do
          expect(result).to eql DateTime.strptime(value, format)
        end
      end
    end

    context 'with an invalid String' do
      let(:value) { 'invalid' }

      it 'raises an error' do
        expect do
          result
        end.to raise_error ActiveInteraction::InvalidValueError
      end

      context 'with format' do
        include_context 'with format'

        it 'raises an error' do
          expect do
            result
          end.to raise_error ActiveInteraction::InvalidValueError
        end
      end
    end

    context 'with an implicit String' do
      let(:value) do
        Class.new do
          def to_str
            '2011-12-13T14:15:16+17:18'
          end
        end.new
      end

      it 'returns a DateTime' do
        expect(result).to eql DateTime.parse(value)
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

      it 'returns a DateTime' do
        expect(
          result
        ).to eql DateTime.new(year, month, day, hour, min, sec)
      end
    end

    context 'with an invalid GroupedInput' do
      context 'empty' do
        let(:value) { ActiveInteraction::GroupedInput.new }

        it 'raises an error' do
          expect do
            result
          end.to raise_error ActiveInteraction::InvalidValueError
        end
      end

      context 'partial inputs' do
        let(:value) do
          ActiveInteraction::GroupedInput.new(
            '2' => '1'
          )
        end

        it 'raises an error' do
          expect do
            result
          end.to raise_error ActiveInteraction::InvalidValueError
        end
      end
    end
  end

  describe '#database_column_type' do
    it 'returns :datetime' do
      expect(filter.database_column_type).to eql :datetime
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
