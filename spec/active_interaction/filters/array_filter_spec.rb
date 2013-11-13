require 'spec_helper'

describe ActiveInteraction::ArrayFilter, :filter do
  let(:name) { SecureRandom.hex.to_sym }
  let(:options) { {} }

  subject(:filter) { described_class.new(name, options) }

  context do
    subject(:filter) { described_class.new(name, options) do
      array
      array
    end }

    it do
      expect { filter }.to raise_error(ActiveInteraction::InvalidFilter)
    end
  end

  context do
    subject(:filter) { described_class.new(name, options) do
      array :a
    end }

    it do
      expect { filter }.to raise_error(ActiveInteraction::InvalidFilter)
    end
  end

  context do
    subject(:filter) { described_class.new(name, options) do
      array default: nil
    end }

    it do
      expect { filter }.to raise_error(ActiveInteraction::InvalidFilter)
    end
  end

  describe '#cast' do
    context do
      let(:value) { [] }

      it do
        expect(filter.cast(value)).to eq value
      end
    end

    context do
      let(:value) { [[], false, 0.0, {}, 0, '', :''] }

      it do
        expect(filter.cast(value)).to eq value
      end
    end

    context do
      subject(:filter) { described_class.new(name, options) do
        array
      end }

      context do
        let(:value) { [] }

        it do
          expect(filter.cast(value)).to eq value
        end
      end

      context do
        let(:value) { [[]] }

        it do
          expect(filter.cast(value)).to eq value
        end
      end

      context do
        let(:value) { [[], false, 0.0, {}, 0, '', :''] }

        it do
          expect{ filter.cast(value) }.to raise_error(ActiveInteraction::InvalidValue)
        end
      end
    end
  end
end
