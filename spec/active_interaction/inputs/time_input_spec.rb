require 'spec_helper'

describe ActiveInteraction::TimeInput, :input do
  let(:name) { SecureRandom.hex.to_sym }
  let(:options) { {} }

  subject(:input) { described_class.new(name, options) }

  describe '#cast' do
    context do
      let(:value) { Time.new }

      it do
        expect(input.cast(value)).to eq value
      end
    end

    context do
      let(:value) { '2011-12-13 14:15:16 +1718' }

      it do
        expect(input.cast(value)).to eq Time.parse(value)
      end

      context do
        let(:format) { '%d/%m/%Y %H:%M:%S %z' }
        let(:value) { '13/12/2011 14:15:16 +1718' }

        before do
          options.merge!(format: format)
        end

        it do
          expect(input.cast(value)).to eq Time.strptime(value, format)
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
