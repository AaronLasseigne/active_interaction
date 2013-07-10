require 'spec_helper'

describe ActiveInteraction::IntegerFilter do
  describe '#prepare(key, value, options = {})' do
    context 'value is a String' do
      it 'converts Strings that are only digits' do
        expect(described_class.prepare(:key, '1')).to eql 1
      end

      it 'errors on all other Strings' do
        expect {
          described_class.prepare(:key, '1a')
        }.to raise_error ActiveInteraction::InvalidValue
      end
    end

    context 'value is an Integer' do
      it 'passes it on through' do
        expect(described_class.prepare(:key, 1)).to eql 1
      end
    end

    it 'throws an error for everything else' do
      expect {
        described_class.prepare(:key, true)
      }.to raise_error ActiveInteraction::InvalidValue
    end

    it_behaves_like 'options includes :allow_nil'
  end
end
