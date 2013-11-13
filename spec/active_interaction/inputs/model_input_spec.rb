require 'spec_helper'

describe ActiveInteraction::ModelInput, :input do
  let(:name) { SecureRandom.hex.to_sym }
  let(:options) { {} }

  subject(:input) { described_class.new(name, options) }

  describe '#cast' do
    let(:value) { Random.new }

    it do
      expect { input.cast(value) }.to raise_error(ActiveInteraction::Error)
    end

    context do
      before do
        options.merge!(class: Random)
      end

      it do
        expect(input.cast(value)).to eq value
      end
    end

    context do
      before do
        options.merge!(class: 'random')
      end

      it do
        expect(input.cast(value)).to eq value
      end
    end

    context do
      before do
        options.merge!(class: :random)
      end

      it do
        expect(input.cast(value)).to eq value
      end
    end

    context do
      before do
        options.merge!(class: 'invalid')
      end

      it do
      expect { input.cast(value) }.to raise_error(ActiveInteraction::Error)
      end
    end
  end
end
