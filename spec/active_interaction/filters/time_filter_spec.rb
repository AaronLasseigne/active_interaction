require 'spec_helper'

describe ActiveInteraction::TimeFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  shared_context 'with format' do
    let(:format) { '%d/%m/%Y %H:%M:%S %z' }

    before do
      options.merge!(format: format)
    end
  end

  describe '#cast' do
    context 'with a Time' do
      let(:value) { Time.new }

      it 'returns the Time' do
        expect(filter.cast(value)).to eq value
      end
    end

    context 'with a String' do
      let(:value) { '2011-12-13 14:15:16 +1718' }

      it 'returns a Time' do
        expect(filter.cast(value)).to eq Time.parse(value)
      end

      context 'with format' do
        include_context 'with format'

        let(:value) { '13/12/2011 14:15:16 +1718' }

        it 'returns a Time' do
          expect(filter.cast(value)).to eq Time.strptime(value, format)
        end
      end
    end

    context 'with an invalid String' do
      let(:value) { 'invalid' }

      it 'raises an error' do
        expect {
          filter.cast(value)
        }.to raise_error ActiveInteraction::InvalidValue
      end

      context 'with format' do
        include_context 'with format'

        it do
          expect {
            filter.cast(value)
          }.to raise_error ActiveInteraction::InvalidValue
        end
      end
    end
  end
end
