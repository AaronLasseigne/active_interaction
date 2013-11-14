require 'spec_helper'

describe ActiveInteraction::BooleanFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '#cast' do
    context 'with false' do
      let(:value) { false }

      it 'returns false' do
        expect(filter.cast(value)).to be_false
      end
    end

    context 'with true' do
      let(:value) { true }

      it 'returns true' do
        expect(filter.cast(value)).to be_true
      end
    end

    context 'with "0"' do
      let(:value) { '0' }

      it 'returns false' do
        expect(filter.cast(value)).to be_false
      end
    end

    context 'with "1"' do
      let(:value) { '1' }

      it 'returns true' do
        expect(filter.cast(value)).to be_true
      end
    end
  end
end
