require 'spec_helper'

describe ActiveInteraction::DateTimeInput, :input do
  let(:name) { SecureRandom.hex.to_sym }
  let(:options) { {} }

  subject(:input) { described_class.new(name, options) }

  describe '#cast' do
    context do
      let(:value) { DateTime.new }

      it do
        expect(input.cast(value)).to eq value
      end
    end

    context do
      let(:value) { '2011-12-13T14:15:16+17:18' }

      it do
        expect(input.cast(value)).to eq DateTime.parse(value)
      end

      context do
        let(:format) { '%d/%m/%Y %H:%M:%S %:z' }
        let(:value) { '13/12/2011 14:15:16 +17:18' }

        before do
          options.merge!(format: format)
        end

        it do
          expect(input.cast(value)).to eq DateTime.strptime(value, format)
        end
      end
    end

    context do
      let(:value) { 'invalid' }

      it do
        expect { input.cast(value) }.to raise_error(ActiveInteraction::InvalidValue)
      end

      context do
        let(:format) { '%d/%m/%Y' }

        before do
          options.merge!(format: format)
        end

        it do
          expect { input.cast(value) }.to raise_error(ActiveInteraction::InvalidValue)
        end
      end
    end
  end
end
