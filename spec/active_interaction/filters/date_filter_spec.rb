require 'spec_helper'

describe ActiveInteraction::DateFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  shared_context 'with format' do
    let(:format) { '%d/%m/%Y' }

    before do
      options[:format] = format
    end
  end

  describe '#cast' do
    let(:result) { filter.cast(value, nil) }

    context 'with a Date' do
      let(:value) { Date.new }

      it 'returns the Date' do
        expect(result).to eql value
      end
    end

    context 'with a String' do
      let(:value) { '2011-12-13' }

      it 'returns a Date' do
        expect(result).to eql Date.parse(value)
      end

      context 'with format' do
        include_context 'with format'

        let(:value) { '13/12/2011' }

        it 'returns a Date' do
          expect(result).to eql Date.strptime(value, format)
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
            '2011-12-13'
          end
        end.new
      end

      it 'returns a Date' do
        expect(result).to eql Date.parse(value)
      end
    end

    context 'with a GroupedInput' do
      let(:year) { 2012 }
      let(:month) { 1 }
      let(:day) { 2 }
      let(:value) do
        ActiveInteraction::GroupedInput.new(
          '1' => year.to_s,
          '2' => month.to_s,
          '3' => day.to_s
        )
      end

      it 'returns a Date' do
        expect(result).to eql Date.new(year, month, day)
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
    it 'returns :date' do
      expect(filter.database_column_type).to eql :date
    end
  end

  describe '#default' do
    context 'with a GroupedInput' do
      before do
        options[:default] = ActiveInteraction::GroupedInput.new(
          '1' => '2012',
          '2' => '1',
          '3' => '2'
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
