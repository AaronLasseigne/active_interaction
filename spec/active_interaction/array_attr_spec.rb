require 'spec_helper'

describe ActiveInteraction::ArrayAttr do
  describe '#prepare(value, options = {})' do
    it 'passes an Array through' do
      expect(described_class.prepare([1])).to eq [1]
    end

    it 'throws an argument error for everything else' do
      expect {
        described_class.prepare(1)
      }.to raise_error ArgumentError
    end

    it_behaves_like 'options includes :allow_nil'
  end
end
