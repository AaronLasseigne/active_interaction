require 'spec_helper'

describe ActiveInteraction::DateTimeAttr do
  describe '#prepare' do
    let(:key) { SecureRandom.hex.to_sym }

    it_behaves_like 'options includes :allow_nil'

    it 'passes a DateTime through' do
      value = DateTime.new
      expect(described_class.prepare(key, value)).to eql value
    end

    it 'throws an argument error for everything else' do
      expect { described_class.prepare(key, 0) }.to raise_error ArgumentError
    end
  end
end
