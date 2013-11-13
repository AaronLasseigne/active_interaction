require 'spec_helper'

describe ActiveInteraction::StringFilter, :filter do
  let(:name) { SecureRandom.hex.to_sym }
  let(:options) { {} }

  subject(:filter) { described_class.new(name, options) }

  describe '#cast' do
    context do
      let(:value) { SecureRandom.hex }

      it do
        expect(filter.cast(value)).to eq value
      end
    end

    context do
      let(:value) { " #{SecureRandom.hex} " }

      it do
        expect(filter.cast(value)).to eq value.strip
      end

      context do
        before do
          options.merge!(strip: false)
        end

        it do
          expect(filter.cast(value)).to eq value
        end
      end
    end
  end
end
