require 'spec_helper'

describe ActiveInteraction::DateTimeFilter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '.prepare(key, value, options = {}, &block)' do
    context 'with a DateTime' do
      let(:value) { DateTime.now }

      it 'returns the DateTime' do
        expect(result).to eql value
      end
    end

    context 'with a valid String' do
      let(:value) { '2001-01-01T01:01:01+01:01' }

      it 'parses the String' do
        expect(result).to eql DateTime.parse(value)
      end
    end

    context 'with an invalid String' do
      let(:value) { 'not a valid DateTine' }

      it 'raises an error' do
        expect { result }.to raise_error ActiveInteraction::InvalidValue
      end
    end
  end
end
