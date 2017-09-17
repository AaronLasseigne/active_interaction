require 'spec_helper'

describe ActiveInteraction::Filter, :filter do
  include_context 'filters'

  describe '#database_column_type' do
    it 'returns `:string`' do
      expect(subject.database_column_type).to eql :string
    end
  end

  context 'with an unregistered subclass' do
    let(:described_class) { Class.new(ActiveInteraction::Filter) }

    describe '.slug' do
      it 'is nil' do
        expect(described_class.slug).to be_nil
      end
    end
  end

  context 'with a registered subclass' do
    it_behaves_like 'a filter'

    let(:described_class) do
      s = slug
      Class.new(ActiveInteraction::Filter) do
        register s
      end
    end
    let(:slug) { SecureRandom.hex.to_sym }

    describe '.slug' do
      it 'returns the registered slug' do
        expect(described_class.slug).to eql slug
      end
    end
  end
end
