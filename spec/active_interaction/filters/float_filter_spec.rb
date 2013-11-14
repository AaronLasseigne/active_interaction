require 'spec_helper'

describe ActiveInteraction::FloatFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '#cast' do
    context 'with a Float' do
      let(:value) { rand }

      it 'returns the Float' do
        expect(filter.cast(value)).to eq value
      end
    end

    context 'with a Numeric' do
      let(:value) { rand(1 << 16) }

      it 'returns a Float' do
        expect(filter.cast(value)).to eq value.to_f
      end
    end

    context 'with a String' do
      let(:value) { rand.to_s }

      it 'returns a Float' do
        expect(filter.cast(value)).to eq Float(value)
      end
    end

    context 'with an invalid String' do
      let(:value) { 'invalid' }

      it 'raises an error' do
        expect {
          filter.cast(value)
        }.to raise_error ActiveInteraction::InvalidValueError
      end
    end
  end
end
