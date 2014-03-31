# coding: utf-8

require 'spec_helper'

module ActiveInteraction
  class TestFilter < ActiveInteraction::Filter; end
end
class TestFilter < ActiveInteraction::Filter; end

describe ActiveInteraction::Filter, :filter do
  include_context 'filters'

  describe '.slug' do
    it 'raises an error' do
      expect do
        described_class.slug
      end.to raise_error ActiveInteraction::InvalidClassError
    end
  end

  context ActiveInteraction::TestFilter do
    it_behaves_like 'a filter'

    let(:described_class) { ActiveInteraction::TestFilter }
  end

  context TestFilter do
    let(:described_class) { TestFilter }

    describe '.factory' do
      it 'returns a Filter' do
        expect(described_class.factory(described_class.name.to_sym))
          .to eq described_class
      end
    end

    describe '.slug' do
      it 'raises an error' do
        expect do
          described_class.slug
        end.to raise_error ActiveInteraction::InvalidClassError
      end
    end
  end
end
