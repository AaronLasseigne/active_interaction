require 'spec_helper'

class ActiveInteraction::RSpecInput < ActiveInteraction::Input
end

describe ActiveInteraction::Input, :input do
  let(:name) { SecureRandom.hex.to_sym }
  let(:options) { {} }

  subject(:input) { described_class.new(name, options) }

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
      expect { described_class.factory(:'') }.to raise_error(ActiveInteraction::MissingInput)
    end

    it do
      expect(described_class.factory(:r_spec)).to eq ActiveInteraction::RSpecInput
    end
  end

  describe '.slug' do
    it do
      expect { described_class.slug }.to raise_error(ActiveInteraction::InvalidInput)
    end

    context do
      let(:described_class) { ActiveInteraction::RSpecInput }

      it do
        expect(described_class.slug).to eq(:r_spec)
      end
    end
  end

  describe '#cast' do
    let(:value) { nil }

    it do
      expect { input.cast(value) }.to raise_error(ActiveInteraction::MissingValue)
    end

    context do
      include_context 'with valid default'

      it do
        expect(input.cast(value)).to be_nil
      end
    end

    context do
      include_context 'with invalid default'

      it do
        expect(input.cast(value)).to be_nil
      end
    end

    context do
      let(:value) { Object.new }

      it do
        expect { input.cast(value) }.to raise_error(ActiveInteraction::InvalidValue)
      end
    end
  end

  describe '#clean' do
    let(:value) { nil }

    it do
      expect { input.clean(value) }.to raise_error(ActiveInteraction::MissingValue)
    end

    context do
      include_context 'with valid default'

      it do
        expect(input.clean(value)).to eq options[:default]
      end
    end

    context do
      include_context 'with invalid default'

      it do
        expect { input.clean(value) }.to raise_error(ActiveInteraction::InvalidDefault)
      end
    end

    context do
      let(:value) { Object.new }

      it do
        expect { input.clean(value) }.to raise_error(ActiveInteraction::InvalidValue)
      end
    end
  end

  describe '#default' do
    it do
      expect { input.default }.to raise_error(ActiveInteraction::MissingDefault)
    end

    context do
      include_context 'with valid default'

      it do
        expect(input.default).to eq options[:default]
      end
    end

    context do
      include_context 'with invalid default'

      it do
        expect { input.default }.to raise_error(ActiveInteraction::InvalidDefault)
      end
    end
  end

  describe '#hash' do
    it do
      expect { input.hash }.to raise_error(NoMethodError)
    end
  end

  describe '#inputs' do
    it do
      expect(input.inputs).to eq []
    end
  end

  describe '#name' do
    it do
      expect(input.name).to eq name
    end
  end

  describe '#optional?' do
    it do
      expect(input).to_not be_optional
    end

    context do
      include_context 'with valid default'

      it do
        expect(input).to be_optional
      end
    end
  end

  describe '#required?' do
    it do
      expect(input).to be_required
    end

    context do
      include_context 'with valid default'

      it do
        expect(input).to_not be_required
      end
    end
  end
end
