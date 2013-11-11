require 'spec_helper'

describe ActiveInteraction::TimeCaster do
  include_context 'casters', ActiveInteraction::TimeFilter
  it_behaves_like 'a caster', ActiveInteraction::TimeFilter

  describe '.prepare(filter, value)' do
    context 'with a Time' do
      let(:value) { Time.now }

      it 'returns the Time' do
        expect(result).to eql value
      end
    end

    shared_examples 'conversion' do
      context 'with a Float' do
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

        context 'with options[:format]' do
          let(:value) { '01010101012001' }

          before { options.merge!(format: '%S%M%H%d%m%Y') }

          it 'parses the String' do
            expect(result).to eql Time.strptime(value, options[:format])
          end
        end
      end

      context 'with an invalid String' do
        let(:value) { 'not a valid Time' }

        it 'raises an error' do
          expect { result }.to raise_error ActiveInteraction::InvalidValue
        end

        context 'with options[:format]' do
          before { options.merge!(format: '%S%M%H%d%m%Y') }

          it 'raises an error' do
            expect { result }.to raise_error ActiveInteraction::InvalidValue
          end
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
          expect(Time).to have_received(:zone).at_least(1).times.with(no_args)
        end
      end

      context 'as Time' do
        include_examples 'conversion'

        before do
          allow(Time).to receive(:zone).and_return(Time)
        end

        after do
          expect(Time).to have_received(:zone).at_least(1).times.with(no_args)
        end
      end
    end
  end
end
