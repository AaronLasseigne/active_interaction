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

  describe '#[]' do
    let(:filter) { double(name: name) }
    let(:name) { SecureRandom.hex.to_sym }

    it 'returns nil' do
      expect(subject[name]).to be_nil
    end

    context 'with a filter' do
      before do
        subject.add(filter)
      end

      it 'returns the filter' do
        expect(subject[name]).to eq filter
      end
    end
  end
end
