# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::FloatFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '#cast' do
    context 'with a Float' do
      let(:value) { rand }

      it 'returns the Float' do
        expect(filter.cast(value)).to eql value
      end
    end

    context 'with a Numeric' do
      let(:value) { rand(1 << 16) }

      it 'returns a Float' do
        expect(filter.cast(value)).to eql value.to_f
      end
    end

    context 'with a String' do
      let(:value) { rand.to_s }

      it 'returns a Float' do
        expect(filter.cast(value)).to eql Float(value)
      end
    end

    context 'with an invalid String' do
      let(:value) { 'invalid' }

      it 'raises an error' do
        expect do
          filter.cast(value)
        end.to raise_error ActiveInteraction::InvalidValueError
      end
    end
  end
end
