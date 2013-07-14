require 'spec_helper'

module ActiveInteraction
  TestFilter = Class.new(Filter)
end

describe ActiveInteraction::Filter do
  it_behaves_like 'a filter'

  describe '.factory(type)' do
    let(:result) { described_class.factory(type) }

    context 'with a valid type' do
      let(:type) { :test }

      it 'returns the Class' do
        expect(result).to eql ActiveInteraction::TestFilter
      end
    end

    context 'with an invalid type' do
      let(:type) { :not_a_valid_type }

      it 'raises an error' do
        expect { result }.to raise_error NoMethodError
      end
    end
  end
end
