require 'spec_helper'

describe ActiveInteraction::FloatCaster do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '.prepare(key, value, options = {}, &block)' do
    context 'with a Float' do
      let(:value) { rand }

      it 'returns the Float' do
        expect(result).to eql value
      end
    end

    context 'with an Integer' do
      let(:value) { rand(1 << 16) }

      it 'converts the Integer' do
        expect(result).to eql Float(value)
      end
    end

    context 'with a valid String' do
      let(:value) { rand.to_s }

      it 'converts the String' do
        expect(result).to eql Float(value)
      end
    end

    context 'with an invalid String' do
      let(:value) { 'not a valid Float' }

      it 'raises an error' do
        expect { result }.to raise_error ActiveInteraction::InvalidValue
      end
    end
  end
end
