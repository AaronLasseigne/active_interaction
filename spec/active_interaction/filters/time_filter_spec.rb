require 'spec_helper'

describe ActiveInteraction::TimeFilter do
  describe '#prepare' do
    let(:key) { SecureRandom.hex.to_sym }

    it_behaves_like 'options includes :allow_nil'

    it 'passes a Time through' do
      value = Time.new
      expect(described_class.prepare(key, value)).to eql value
    end

    context 'Time.zone does not exist' do
      it 'converts an integer' do
        value = rand(1 << 30)
        allow(Time).to receive(:at)

        described_class.prepare(key, value)

        expect(Time).to have_received(:at).with(value).once
      end

      it 'converts a float' do
        value = rand(1 << 30) + rand
        allow(Time).to receive(:at)

        described_class.prepare(key, value)

        expect(Time).to have_received(:at).with(value).once
      end
    end

    context 'Time.zone exists' do
      before(:each) do
        @time_zone_class = double
        allow(Time).to receive(:zone).and_return(@time_zone_class)
      end

      it 'converts an integer' do
        value = rand(1 << 30)
        allow(@time_zone_class).to receive(:at)

        described_class.prepare(key, value)

        expect(@time_zone_class).to have_received(:at).with(value).once
      end

      it 'converts a float' do
        value = rand(1 << 30) + rand
        allow(@time_zone_class).to receive(:at)

        described_class.prepare(key, value)

        expect(@time_zone_class).to have_received(:at).with(value).once
      end
    end

    it 'throws an error for everything else' do
      expect { described_class.prepare(key, '') }.to raise_error ActiveInteraction::InvalidValue
    end
  end
end
