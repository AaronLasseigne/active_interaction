# coding: utf-8

require 'spec_helper'

module ActiveInteraction
  class ATestFilter < ActiveInteraction::Filter; end
end
class ATestFilter < ActiveInteraction::Filter; end

describe ActiveInteraction::Filter, :filter do
  include_context 'filters'

  describe '#database_column_type' do
    it 'returns `:string`' do
      expect(subject.database_column_type).to eql :string
    end
  end

  context ActiveInteraction::ATestFilter do
    it_behaves_like 'a filter'

    let(:described_class) { ActiveInteraction::ATestFilter }

    describe '.slug' do
      it 'returns a slug representing the class' do
        expect(described_class.slug).to eql :a_test
      end
    end
  end

  context ATestFilter do
    let(:described_class) { ATestFilter }

    describe '.factory' do
      it 'returns a Filter' do
        expect(described_class.factory(described_class.name.to_sym))
          .to eql described_class
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
