require 'spec_helper'

describe ActiveInteraction::StringInput, :input do
  let(:name) { SecureRandom.hex.to_sym }
  let(:options) { {} }

  subject(:input) { described_class.new(name, options) }

  describe '#cast' do
    context do
      let(:value) { SecureRandom.hex }

      it do
        expect(input.cast(value)).to eq value
      end
    end

    context do
      let(:value) { " #{SecureRandom.hex} " }

      it do
        expect(input.cast(value)).to eq value.strip
      end

      context do
        before do
          options.merge!(strip: false)
        end

        it do
          expect(input.cast(value)).to eq value
        end
      end
    end
  end
end
