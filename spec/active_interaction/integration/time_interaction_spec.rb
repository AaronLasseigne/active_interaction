require 'spec_helper'

class TimeZone
  def self.at(*args)
    TimeWithZone.at(*args)
  end
end

class TimeWithZone
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

class TimeInteraction < ActiveInteraction::Base
  time :a

  def execute
    a
  end
end

describe TimeInteraction do
  include_context 'interactions'
  it_behaves_like 'an interaction', :time, -> { Time.now }

  context 'with a time zone' do
    let(:a) { rand(1 << 16) }

    before do
      allow(Time).to receive(:zone).and_return(TimeZone)
      options.merge!(a: a)
    end

    it 'returns the correct value' do
      expect(result).to eq Time.at(a)
    end
  end
end
