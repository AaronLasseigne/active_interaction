require 'spec_helper'

class ActiveInteraction::RSpecFilter < ActiveInteraction::Filter
end

describe ActiveInteraction::Filter, :filter do
  let(:name) { SecureRandom.hex.to_sym }
  let(:options) { {} }

  subject(:filter) { described_class.new(name, options) }

  shared_context 'with invalid default' do
    before do
      options.merge!(default: Object.new)
    end
  end

  shared_context 'with valid default' do
    before do
      options.merge!(default: nil)
    end
  end

  describe '.factory' do
    it do
      expect { described_class.factory(:'') }.to raise_error(ActiveInteraction::MissingFilter)
    end

    it do
      expect(described_class.factory(:r_spec)).to eq ActiveInteraction::RSpecFilter
    end
  end

  describe '.slug' do
    it do
      expect { described_class.slug }.to raise_error(ActiveInteraction::InvalidClass)
    end

    context do
      let(:described_class) { ActiveInteraction::RSpecFilter }

      it do
        expect(described_class.slug).to eq(:r_spec)
      end
    end
  end

  describe '#cast' do
    let(:value) { nil }

    it do
      expect { filter.cast(value) }.to raise_error(ActiveInteraction::MissingValue)
    end

    context do
      include_context 'with valid default'

      it do
        expect(filter.cast(value)).to be_nil
      end
    end

    context do
      include_context 'with invalid default'

      it do
        expect(filter.cast(value)).to be_nil
      end
    end

    context do
      let(:value) { Object.new }

      it do
        expect { filter.cast(value) }.to raise_error(ActiveInteraction::InvalidValue)
      end
    end
  end

  describe '#clean' do
    let(:value) { nil }

    it do
      expect { filter.clean(value) }.to raise_error(ActiveInteraction::MissingValue)
    end

    context do
      include_context 'with valid default'

      it do
        expect(filter.clean(value)).to eq options[:default]
      end
    end

    context do
      include_context 'with invalid default'

      it do
        expect { filter.clean(value) }.to raise_error(ActiveInteraction::InvalidDefault)
      end
    end

    context do
      let(:value) { Object.new }

      it do
        expect { filter.clean(value) }.to raise_error(ActiveInteraction::InvalidValue)
      end
    end
  end

  describe '#default' do
    it do
      expect { filter.default }.to raise_error(ActiveInteraction::MissingDefault)
    end

    context do
      include_context 'with valid default'

      it do
        expect(filter.default).to eq options[:default]
      end
    end

    context do
      include_context 'with invalid default'

      it do
        expect { filter.default }.to raise_error(ActiveInteraction::InvalidDefault)
      end
    end
  end

  describe '#hash' do
    it do
      expect { filter.hash }.to raise_error(NoMethodError)
    end
  end

  describe '#filters' do
    it do
      expect(filter.filters).to be_an(ActiveInteraction::Filters)
    end
  end

  describe '#name' do
    it do
      expect(filter.name).to eq name
    end
  end

  describe '#optional?' do
    it do
      expect(filter).to_not be_optional
    end

    context do
      include_context 'with valid default'

      it do
        expect(filter).to be_optional
      end
    end
  end

  describe '#required?' do
    it do
      expect(filter).to be_required
    end

    context do
      include_context 'with valid default'

      it do
        expect(filter).to_not be_required
      end
    end
  end
end
