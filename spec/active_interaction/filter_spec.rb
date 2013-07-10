require 'spec_helper'

describe ActiveInteraction::Filter do
  describe '.factory(type)' do
    it 'returns the full name of the filter class matching the type' do
      expect(described_class.factory(:integer)).to eq ActiveInteraction::IntegerFilter
    end

    it 'raises a NoMethodError if the type does not match a filter class' do
      expect {
        described_class.factory(:not_a_valid_type)
      }.to raise_error NoMethodError
    end
  end
end
