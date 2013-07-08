require 'spec_helper'

describe ActiveInteraction::Attr do
  describe '.factory(attr_type)' do
    it 'returns the full name of the attr module matching the attr_type' do
      expect(described_class.factory(:integer)).to eq ActiveInteraction::IntegerAttr
    end

    it 'raises a NoMethodError if the attr_type does not match an attr module' do
      expect {
        described_class.factory(:not_an_attr_module)
      }.to raise_error NoMethodError
    end
  end
end
