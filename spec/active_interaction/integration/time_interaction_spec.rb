# coding: utf-8

require 'spec_helper'

TimeZone = Class.new do
  def self.at(*args)
    TimeWithZone.at(*args)
  end
end

TimeWithZone = Class.new do
  def self.at(*args)
    new(Time.at(*args))
  end

  def initialize(time)
    @time = time
  end

  def ==(other)
    @time == other
  end
end

TimeInteraction = Class.new(TestInteraction) do
  time :a
end

describe TimeInteraction do
  include_context 'interactions'
  it_behaves_like 'an interaction', :time, -> { Time.now }

  context 'with a time zone' do
    let(:a) { rand(1 << 16) }

    before do
      allow(Time).to receive(:zone).and_return(TimeZone)
      inputs.merge!(a: a)
    end

    it 'returns the correct value' do
      expect(result[:a]).to eq Time.at(a)
    end
  end
end
