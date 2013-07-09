require 'spec_helper'

describe ActiveInteraction::BooleanAttr do
  describe '#prepare(key, value, options = {})' do
    it 'sets `true` to `true`' do
      expect(described_class.prepare(:key, true)).to eql true
    end

    it 'sets `false` to `false`' do
      expect(described_class.prepare(:key, false)).to eql false
    end

    it 'sets "1" to `true`' do
      expect(described_class.prepare(:key, '1')).to eql true
    end

    it 'sets "0" to `false`' do
      expect(described_class.prepare(:key, '0')).to eql false
    end

    it 'throws an argument error for everything else' do
      expect {
        described_class.prepare(:key, 1)
      }.to raise_error ArgumentError
    end

    it_behaves_like 'options includes :allow_nil'
  end
end
