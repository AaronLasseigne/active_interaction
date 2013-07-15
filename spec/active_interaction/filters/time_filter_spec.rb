require 'spec_helper'

describe ActiveInteraction::TimeFilter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '.prepare(key, value, options = {}, &block)' do
    context 'with a Time' do
      let(:value) { Time.now }

      it 'returns the Time' do
        expect(result).to eql value
      end
    end

    shared_examples 'conversion' do
      context 'with a float' do
        let(:value) { rand }

        it 'converts the Float' do
          expect(result).to eql Time.at(value)
        end
      end

      context 'with an Integer' do
        let(:value) { rand(1 << 16) }

        it 'converts the Integer' do
          expect(result).to eql Time.at(value)
        end
      end

      context 'with a valid String' do
        let(:value) { '2001-01-01T01:01:01+01:01' }

        it 'parses the String' do
          expect(result).to eql Time.parse(value)
        end
      end

      context 'with an invalid String' do
        let(:value) { 'not a valid Time' }

        it 'raises an error' do
          expect { result }.to raise_error ActiveInteraction::InvalidValue
        end
      end
    end

    context 'without Time.zone' do
      include_examples 'conversion'
    end

    context 'with Time.zone' do
      context 'as nil' do
        include_examples 'conversion'

        before do
          allow(Time).to receive(:zone).and_return(nil)
        end

        after do
          expect(Time).to have_received(:zone).once.with(no_args)
        end
      end

      context 'as Time' do
        include_examples 'conversion'

        before do
          allow(Time).to receive(:zone).and_return(Time)
        end

        after do
          expect(Time).to have_received(:zone).twice.with(no_args)
        end
      end
    end
  end
end
