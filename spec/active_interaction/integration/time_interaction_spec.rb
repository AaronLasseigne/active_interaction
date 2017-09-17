require 'spec_helper'

TimeZone = Class.new do
  def self.at(*args)
    TimeWithZone.new(Time.at(*args))
  end

  def self.parse(*args)
    TimeWithZone.new(Time.parse(*args))
  rescue ArgumentError
    nil
  end
end

TimeWithZone = Class.new do
  attr_reader :time

  def initialize(time)
    @time = time
  end

  def ==(other)
    time == other.time
  end
end

TimeInteraction = Class.new(TestInteraction) do
  time :a
end

describe TimeInteraction do
  include_context 'interactions'
  it_behaves_like 'an interaction', :time, -> { Time.now }

  context 'with a time zone' do
    let(:a) { nil }

    before do
      inputs[:a] = a

      allow(Time).to receive(:zone).and_return(TimeZone)
    end

    context 'with an integer' do
      let(:a) { rand(1 << 16) }

      it 'returns the correct value' do
        expect(result[:a]).to eq TimeZone.at(a)
      end
    end

    context 'with a string' do
      let(:a) { '2011-12-13T14:15:16Z' }

      it 'returns the correct value' do
        expect(result[:a]).to eq TimeZone.parse(a)
      end
    end

    context 'with an invalid String' do
      let(:a) { 'invalid' }

      it 'is invalid' do
        expect(outcome).to be_invalid
      end
    end

    context 'with a Time' do
      let(:a) { Time.now }

      it 'returns the correct value' do
        expect(result[:a]).to eql a
      end
    end

    context 'with a TimeZone' do
      let(:a) { TimeWithZone.new(Time.now) }

      it 'returns the correct value' do
        expect(result[:a]).to eql a
      end

      it 'handles time zone changes' do
        outcome
        allow(Time).to receive(:zone).and_return(nil)
        expect(described_class.run(inputs)).to be_invalid
      end
    end
  end
end
