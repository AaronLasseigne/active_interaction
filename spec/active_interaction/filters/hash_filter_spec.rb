require 'spec_helper'

describe ActiveInteraction::HashFilter, :filter do
  let(:name) { SecureRandom.hex.to_sym }
  let(:options) { {} }

  subject(:filter) { described_class.new(name, options) }

  context do
    subject(:filter) { described_class.new(name, options) do
      hash
    end }

    it do
      expect { filter }.to raise_error(ActiveInteraction::InvalidFilter)
    end
  end

  describe '#cast' do
    context do
      let(:value) { {} }

      it do
        expect(filter.cast(value)).to eq value
      end
    end

    context do
      let(:value) { { a: {} } }

      it do
        expect(filter.cast(value)).to eq({})
      end
    end

    context do
      let(:value) { { a: {} } }

      subject(:filter) { described_class.new(name, options) do
        hash :a
      end }

      it do
        expect(filter.cast(value)).to eq value
      end
    end
  end
end
