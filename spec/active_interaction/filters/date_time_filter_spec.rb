# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::DateTimeFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  shared_context 'with format' do
    let(:format) { '%d/%m/%Y %H:%M:%S %:z' }

    before do
      options.merge!(format: format)
    end
  end

  describe '#cast' do
    context 'with a Datetime' do
      let(:value) { DateTime.new }

      it 'returns the DateTime' do
        expect(filter.cast(value)).to eq value
      end
    end

    context 'with a String' do
      let(:value) { '2011-12-13T14:15:16+17:18' }

      it 'returns a DateTime' do
        expect(filter.cast(value)).to eq DateTime.parse(value)
      end

      context 'with format' do
        include_context 'with format'

        let(:value) { '13/12/2011 14:15:16 +17:18' }

        it 'returns a DateTime' do
          expect(filter.cast(value)).to eq DateTime.strptime(value, format)
        end
      end
    end

    context 'with an invalid String' do
      let(:value) { 'invalid' }

      it 'raises an error' do
        expect do
          filter.cast(value)
        end.to raise_error ActiveInteraction::InvalidValueError
      end

      context 'with format' do
        include_context 'with format'

        it 'raises an error' do
          expect do
            filter.cast(value)
          end.to raise_error ActiveInteraction::InvalidValueError
        end
      end
    end

    context 'with an Array' do
      let(:year) { 2014 }
      let(:month) { 1 }
      let(:day) { 2 }
      let(:hour) { 3 }
      let(:minute) { 4 }
      let(:second) { 5 }
      let(:value) { [year, month, day, hour, minute, second] }

      it 'returns the Date' do
        expect(filter.cast(value)).to eql DateTime.new(
          year, month, day, hour, minute, second
        )
      end
    end

    context 'with an invalid Array' do
      let(:value) { %w(a b c d e f) }

      it 'raises an error' do
        expect do
          filter.cast(value)
        end.to raise_error ActiveInteraction::InvalidValueError
      end
    end
  end

  describe '#database_column_type' do
    it 'returns :datetime' do
      expect(filter.database_column_type).to eql :datetime
    end
  end
end
