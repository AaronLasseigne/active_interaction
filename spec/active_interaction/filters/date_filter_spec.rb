# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::DateFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  shared_context 'with format' do
    let(:format) { '%d/%m/%Y' }

    before do
      options.merge!(format: format)
    end
  end

  describe '#cast' do
    context 'with a Date' do
      let(:value) { Date.new }

      it 'returns the Date' do
        expect(filter.cast(value)).to eq value
      end
    end

    context 'with a String' do
      let(:value) { '2011-12-13' }

      it 'returns a Date' do
        expect(filter.cast(value)).to eq Date.parse(value)
      end

      context 'with format' do
        include_context 'with format'

        let(:value) { '13/12/2011' }

        it 'returns a Date' do
          expect(filter.cast(value)).to eq Date.strptime(value, format)
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
      let(:value) { [year, month, day] }

      it 'returns the Date' do
        expect(filter.cast(value)).to eql Date.new(year, month, day)
      end
    end

    context 'with an invalid Array' do
      let(:value) { %w(a b c) }

      it 'raises an error' do
        expect do
          filter.cast(value)
        end.to raise_error ActiveInteraction::InvalidValueError
      end
    end
  end
end
