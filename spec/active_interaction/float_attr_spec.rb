require 'spec_helper'

describe ActiveInteraction::FloatAttr do
  describe '#prepare(value, options = {})' do
    context 'value is a String' do
      it 'converts Strings that are only digits' do
        expect(described_class.prepare('1')).to eql 1.0
      end

      it 'errors on all other Strings' do
        expect {
          described_class.prepare('1a')
        }.to raise_error ArgumentError
      end
    end

    context 'value is a Float' do
      it 'passes it on through' do
        expect(described_class.prepare(1.0)).to eql 1.0
      end
    end

    it 'throws an argument error for everything else' do
      expect {
        described_class.prepare(true)
      }.to raise_error ArgumentError
    end

    it_behaves_like 'options includes :allow_nil'
  end
end
