require 'spec_helper'

describe ActiveInteraction::BooleanAttr do
  describe '#prepare(value, options = {})' do
    it 'sets `true` to `true`' do
      expect(described_class.prepare(true)).to eq true
    end

    it 'sets `false` to `false`' do
      expect(described_class.prepare(false)).to eq false
    end

    it 'sets "1" to `true`' do
      expect(described_class.prepare('1')).to eq true
    end

    it 'sets "0" to `false`' do
      expect(described_class.prepare('0')).to eq false
    end

    it 'throws an argument error for everything else' do
      expect {
        described_class.prepare(1)
      }.to raise_error ArgumentError
    end

    it_behaves_like 'options includes :allow_nil'
  end
end
