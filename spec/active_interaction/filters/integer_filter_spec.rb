require 'spec_helper'

describe ActiveInteraction::IntegerFilter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '.prepare(key, value, options = {}, &block)' do
    context 'with an Integer' do
      let(:value) { rand(1 << 16) }

      it 'returns the Integer' do
        expect(result).to eql value
      end
    end

    context 'with a valid String' do
      let(:value) { rand(1 << 16).to_s }

      it 'converts the String' do
        expect(result).to eql Integer(value)
      end
    end

    context 'with an invalid String' do
      let(:value) { 'not a valid Integer' }

      it 'raises an error' do
        expect { result }.to raise_error ActiveInteraction::InvalidValue
      end
    end
  end
end
