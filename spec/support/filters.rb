shared_context 'filters' do
  let(:block) { nil }
  let(:name) { SecureRandom.hex.to_sym }
  let(:options) { {} }

  subject(:filter) { described_class.new(name, options, &block) }

  shared_context 'optional' do
    before do
      options.merge!(default: nil)
    end
  end

  shared_context 'required' do
    before do
      options.delete(:default)
    end
  end
end

shared_examples_for 'a filter' do
  include_context 'filters'

  describe '.factory' do
    context 'with an invalid slug' do
      it 'raises an error' do
        expect {
          described_class.factory(:invalid)
        }.to raise_error ActiveInteraction::MissingFilter
      end
    end

    context 'with a valid slug' do
      it 'returns a Filter' do
        expect(
          described_class.factory(described_class.slug)
        ).to eq described_class
      end
    end
  end

  describe '.slug' do
    it 'returns a symbol' do
      expect(described_class.slug).to be_a Symbol
    end
  end

  describe '#cast' do
    let(:value) { nil }

    context 'optional' do
      include_context 'optional'

      it 'returns nil' do
        expect(filter.cast(value)).to be_nil
      end
    end

    context 'required' do
      include_context 'required'

      it 'raises an error' do
        expect {
          filter.cast(value)
        }.to raise_error ActiveInteraction::MissingValue
      end

      context 'with an invalid default' do
        let(:value) { Object.new }

        it 'raises an error' do
          expect {
            filter.cast(value)
          }.to raise_error ActiveInteraction::InvalidValue
        end
      end
    end
  end

  describe '#clean' do
    let(:value) { nil }

    context 'optional' do
      include_context 'optional'

      it 'returns the default' do
        expect(filter.clean(value)).to eq options[:default]
      end
    end

    context 'required' do
      include_context 'required'

      it 'raises an error' do
        expect {
          filter.clean(value)
        }.to raise_error ActiveInteraction::MissingValue
      end

      context 'with an invalid value' do
        let(:value) { Object.new }

        it 'raises an error' do
          expect {
            filter.clean(value)
          }.to raise_error ActiveInteraction::InvalidValue
        end
      end
    end

    context 'with an invalid default' do
      before do
        options.merge!(default: Object.new)
      end

      it 'raises an error' do
        expect {
          filter.clean(value)
        }.to raise_error ActiveInteraction::InvalidDefault
      end
    end
  end

  describe '#default' do
    context 'optional' do
      include_context 'optional'

      it 'returns the default' do
        expect(filter.default).to eq options[:default]
      end
    end

    context 'required' do
      include_context 'required'

      it 'raises an error' do
        expect {
          filter.default
        }.to raise_error ActiveInteraction::NoDefault
      end
    end

    context 'with an invalid default' do
      before do
        options.merge!(default: Object.new)
      end

      it 'raises an error' do
        expect {
          filter.default
        }.to raise_error ActiveInteraction::InvalidDefault
      end
    end
  end

  describe '#filters' do
    it 'returns Filters' do
      expect(filter.filters).to be_an ActiveInteraction::Filters
    end
  end

  describe '#has_default?' do
    context 'optional' do
      include_context 'optional'

      it 'returns true' do
        expect(filter).to have_default
      end
    end

    context 'required' do
      include_context 'required'

      it 'returns false' do
        expect(filter).to_not have_default
      end
    end
  end

  describe '#name' do
    it 'returns the name' do
      expect(filter.name).to eq name
    end
  end

  describe '#options' do
    it 'returns the options' do
      expect(filter.options).to eq options
    end
  end
end
