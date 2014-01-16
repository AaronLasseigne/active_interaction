# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::Filters do
  describe '#each' do
    it 'returns an Enumerator' do
      expect(subject.each).to be_an Enumerator
    end
  end

  describe '#add(filter)' do
    let(:filter) { double(name: name) }
    let(:name) { SecureRandom.hex.to_sym }

    it 'returns self' do
      expect(subject.add(filter)).to equal subject
    end

    it 'adds the filter' do
      expect(subject.add(filter).to_a).to eql [filter]
    end

    it 'replaces an existing filter' do
      expect(subject.add(filter).add(filter).to_a).to eql [filter]
    end
  end
end
