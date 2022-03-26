require 'spec_helper'

describe ActiveInteraction::Filter, :filter do
  include_context 'filters'

  describe '#database_column_type' do
    it 'returns `:string`' do
      expect(filter.database_column_type).to be :string
    end
  end

  context 'with an unregistered subclass' do
    let(:klass) { Class.new(described_class) }

    describe '.slug' do
      it 'is nil' do
        expect(klass.slug).to be_nil
      end
    end
  end

  context 'with a registered subclass' do
    let(:slug) { SecureRandom.hex.to_sym }
    let(:described_class) do
      s = slug
      Class.new(ActiveInteraction::Filter) do
        register s
      end
    end

    it_behaves_like 'a filter'

    describe '.slug' do
      it 'returns the registered slug' do
        expect(described_class.slug).to eql slug
      end
    end
  end
end
