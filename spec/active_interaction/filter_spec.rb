require 'spec_helper'

describe ActiveInteraction::Filter do
  class ActiveInteraction::TestKlassFilter < described_class; end

  it 'registers subclass type on inheritance' do
    expect(described_class::TYPES['TestKlass']).to eq ActiveInteraction::TestKlassFilter
  end

  describe '.factory(type)' do
    context 'the type is not found' do
      it 'throws a NoMethodError' do
        expect { described_class.factory(:'1') }.to raise_error(NoMethodError)
      end
    end

    context 'the type is found' do
      it 'returns the class of that type' do
        expect(described_class.factory(:test_klass)).to eq ActiveInteraction::TestKlassFilter
      end
    end
  end

  describe '.type' do
    it 'returns the filter type as a symbol' do
      expect(ActiveInteraction::TestKlassFilter.type).to eql :test_klass
    end
  end

  describe '#type' do
    it 'returns the filter type as a symbol' do
      klass = ActiveInteraction::TestKlassFilter.new(SecureRandom.hex)

      expect(klass.type).to eql :test_klass
    end
  end

  describe '#default' do
    let(:name) { SecureRandom.hex }
    let(:options) { {} }

    subject(:filter) { ActiveInteraction::TestKlassFilter.new(name, options) }

    context 'without a default' do
      it 'returns nil' do
        expect(filter.default).to be_nil
      end
    end

    context 'with a default' do
      let(:default) { SecureRandom.hex }
      let(:factory) { double }

      before do
        options.merge!(default: default)
        allow(ActiveInteraction::Caster).to receive(:cast).and_return(default)
      end

      it 'returns the default' do
        expect(filter.default).to eq default
      end

      it 'calls cast' do
        expect(ActiveInteraction::Caster).to receive(:cast).
          once.with(filter, default)
        filter.default
      end
    end
  end
end
