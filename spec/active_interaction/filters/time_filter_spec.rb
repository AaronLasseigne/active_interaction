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
      it 'converts an Integer' do
        value = rand(1 << 30)

        expect(described_class.prepare(key, value)).to eql Time.at(value)
      end

      it 'converts a Float' do
        value = rand(1 << 30) + rand

        expect(described_class.prepare(key, value)).to eql Time.at(value)
      end

      it 'converts a String' do
        value = '2013-01-01 00:00:00'

        expect(described_class.prepare(key, value)).to eql Time.parse(value)
      end

      it 'throws an error for invalid time Strings' do
        expect { described_class.prepare(key, 'a') }.to raise_error ActiveInteraction::InvalidValue
      end
    end

    context 'Time.zone exists' do
      let(:time_zone_class) { double }
      before do
        allow(Time).to receive(:zone).and_return(time_zone_class)
      end

      it 'converts an Integer' do
        value = rand(1 << 30)
        allow(time_zone_class).to receive(:at)

        described_class.prepare(key, value)

        expect(time_zone_class).to have_received(:at).with(value).once
      end

      it 'converts a Float' do
        value = rand(1 << 30) + rand
        allow(time_zone_class).to receive(:at)

        described_class.prepare(key, value)

        expect(time_zone_class).to have_received(:at).with(value).once
      end

      it 'converts a String' do
        value = '2013-01-01 00:00:00'
        allow(time_zone_class).to receive(:parse)

        described_class.prepare(key, value)

        expect(time_zone_class).to have_received(:parse).with(value).once
      end
    end

    it 'throws an error for everything else' do
      expect { described_class.prepare(key, true) }.to raise_error ActiveInteraction::InvalidValue
    end
  end
end
