# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::Filters do
  describe '#each' do
    it 'returns an Enumerator' do
      expect(subject.each).to be_an Enumerator
    end
  end

  describe '#add(filter)' do
    it 'returns self' do
      expect(subject.add(double)).to equal subject
    end

    it 'adds the filter' do
      filter = double

      expect(subject.add(filter).to_a).to eql [filter]
    end
  end
end
