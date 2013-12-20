# coding: utf-8

require 'spec_helper'

TimeZone = Class.new do
  def self.at(*args)
    TimeWithZone.new(Time.at(*args))
  end

  def self.parse(*args)
    TimeWithZone.new(Time.parse(*args))
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
      inputs.merge!(a: a)

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
  end
end
