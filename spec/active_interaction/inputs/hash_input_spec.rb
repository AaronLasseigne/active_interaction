require 'spec_helper'

describe ActiveInteraction::HashInput, :input do
  let(:name) { SecureRandom.hex.to_sym }
  let(:options) { {} }

  subject(:input) { described_class.new(name, options) }

  context do
    subject(:input) { described_class.new(name, options) do
      hash
    end }

    it do
      expect { input }.to raise_error(ActiveInteraction::Error)
    end
  end

  describe '#cast' do
    context do
      let(:value) { {} }

      it do
        expect(input.cast(value)).to eq value
      end
    end

    context do
      let(:value) { { a: {} } }

      it do
        expect(input.cast(value)).to eq({})
      end
    end

    context do
      let(:value) { { a: {} } }

      subject(:input) { described_class.new(name, options) do
        hash :a
      end }

      it do
        expect(input.cast(value)).to eq value
      end
    end
  end
end
