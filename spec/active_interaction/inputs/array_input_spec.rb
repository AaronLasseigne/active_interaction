require 'spec_helper'

describe ActiveInteraction::ArrayInput, :input do
  let(:name) { SecureRandom.hex.to_sym }
  let(:options) { {} }

  subject(:input) { described_class.new(name, options) }

  context do
    subject(:input) { described_class.new(name, options) do
      array
      array
    end }

    it do
      expect { input }.to raise_error(ActiveInteraction::Error)
    end
  end

  context do
    subject(:input) { described_class.new(name, options) do
      array :a
    end }

    it do
      expect { input }.to raise_error(ActiveInteraction::Error)
    end
  end

  context do
    subject(:input) { described_class.new(name, options) do
      array default: nil
    end }

    it do
      expect { input }.to raise_error(ActiveInteraction::Error)
    end
  end

  describe '#cast' do
    context do
      let(:value) { [] }

      it do
        expect(input.cast(value)).to eq value
      end
    end

    context do
      let(:value) { [[], false, 0.0, {}, 0, '', :''] }

      it do
        expect(input.cast(value)).to eq value
      end
    end

    context do
      subject(:input) { described_class.new(name, options) do
        array
      end }

      context do
        let(:value) { [] }

        it do
          expect(input.cast(value)).to eq value
        end
      end

      context do
        let(:value) { [[]] }

        it do
          expect(input.cast(value)).to eq value
        end
      end

      context do
        let(:value) { [[], false, 0.0, {}, 0, '', :''] }

        it do
          expect{ input.cast(value) }.to raise_error(ActiveInteraction::InvalidValue)
        end
      end
    end
  end
end
