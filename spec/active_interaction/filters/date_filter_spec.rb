require 'spec_helper'

describe ActiveInteraction::DateFilter, :filter do
  let(:name) { SecureRandom.hex.to_sym }
  let(:options) { {} }

  subject(:filter) { described_class.new(name, options) }

  describe '#cast' do
    context do
      let(:value) { Date.new }

      it do
        expect(filter.cast(value)).to eq value
      end
    end

    context do
      let(:value) { '2011-12-13' }

      it do
        expect(filter.cast(value)).to eq Date.parse(value)
      end

      context do
        let(:format) { '%d/%m/%Y' }
        let(:value) { '13/12/2011' }

        before do
          options.merge!(format: format)
        end

        it do
          expect(filter.cast(value)).to eq Date.strptime(value, format)
        end
      end
    end

    context do
      let(:value) { 'invalid' }

      it do
        expect { filter.cast(value) }.to raise_error(ActiveInteraction::InvalidValue)
      end

      context do
        let(:format) { '%d/%m/%Y' }

        before do
          options.merge!(format: format)
        end

        it do
          expect { filter.cast(value) }.to raise_error(ActiveInteraction::InvalidValue)
        end
      end
    end
  end
end
