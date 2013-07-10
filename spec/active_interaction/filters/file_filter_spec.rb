require 'spec_helper'

describe ActiveInteraction::FileFilter do
  describe '#prepare(key, value, options = {})' do
    it_behaves_like 'options includes :allow_nil'

    let(:key) { SecureRandom.hex }
    let(:value) {}
    let(:options) { {} }
    let(:result) { described_class.prepare(key, value, options) }

    context 'value is a File' do
      let(:value) { File.open(__FILE__) }

      it 'passes it on through' do
        expect(result).to eql value
      end
    end

    context 'value is not nil' do
      let(:value) { false }

      it 'throws an error' do
        expect { result }.to raise_error ActiveInteraction::InvalidValue
      end
    end
  end
end
