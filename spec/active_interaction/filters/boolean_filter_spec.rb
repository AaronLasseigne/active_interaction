require 'spec_helper'

describe ActiveInteraction::BooleanFilter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '.prepare(key, value, options = {}, &block)' do
    context 'with true' do
      let(:value) { true }

      it 'returns true' do
        expect(result).to eql true
      end
    end

    context 'with false' do
      let(:value) { false }

      it 'returns false' do
        expect(result).to eql false
      end
    end

    context 'with "1"' do
      let(:value) { '1' }

      it 'returns true' do
        expect(result).to eql true
      end
    end

    context 'with "0"' do
      let(:value) { '0' }

      it 'returns false' do
        expect(result).to eql false
      end
    end
  end
end
