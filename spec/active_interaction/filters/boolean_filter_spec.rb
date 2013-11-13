require 'spec_helper'

describe ActiveInteraction::BooleanFilter, :filter do
  let(:name) { SecureRandom.hex.to_sym }
  let(:options) { {} }

  subject(:filter) { described_class.new(name, options) }

  describe '#cast' do
    context do
      let(:value) { false }

      it do
        expect(filter.cast(value)).to be_false
      end
    end

    context do
      let(:value) { true }

      it do
        expect(filter.cast(value)).to be_true
      end
    end

    context do
      let(:value) { '0' }

      it do
        expect(filter.cast(value)).to be_false
      end
    end

    context do
      let(:value) { '1' }

      it do
        expect(filter.cast(value)).to be_true
      end
    end
  end
end
