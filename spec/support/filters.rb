shared_context 'filters' do
  subject(:filter) { described_class.new(name, options, &block) }

  let(:block) { nil }
  let(:name) { SecureRandom.hex.to_sym }
  let(:options) { {} }

  shared_context 'optional' do
    before do
      options[:default] = nil
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
        expect do
          described_class.factory(:invalid)
        end.to raise_error ActiveInteraction::MissingFilterError
      end
    end

    context 'with a valid slug' do
      it 'returns a Filter' do
        expect(
          described_class.factory(described_class.slug)
        ).to eql described_class
      end
    end
  end

  describe '.slug' do
    it 'returns a symbol' do
      expect(described_class.slug).to be_a Symbol
    end
  end

  describe '#process' do
    let(:value) { nil }

    context 'optional' do
      include_context 'optional'

      it 'returns the default' do
        expect(filter.process(value, nil).value).to eql options[:default]
      end
    end

    context 'required' do
      include_context 'required'

      it 'indicates an error' do
        expect(
          filter.process(value, nil).error
        ).to be_an_instance_of ActiveInteraction::MissingValueError
      end

      context 'with an invalid value' do
        let(:value) { Object.new }

        it 'indicates an error' do
          expect(
            filter.process(value, nil).error
          ).to be_an_instance_of ActiveInteraction::InvalidValueError
        end
      end
    end

    context 'with an invalid default' do
      before do
        options[:default] = Object.new
      end

      it 'raises an error' do
        expect do
          filter.process(value, nil)
        end.to raise_error ActiveInteraction::InvalidDefaultError
      end
    end

    # BasicObject is missing a lot of methods
    context 'with a BasicObject' do
      let(:value) { BasicObject.new }

      it 'indicates an error' do
        expect(
          filter.process(value, nil).error
        ).to be_an_instance_of ActiveInteraction::InvalidValueError
      end
    end
  end

  describe '#default' do
    context 'optional' do
      include_context 'optional'

      it 'returns the default' do
        expect(filter.default(nil)).to eql options[:default]
      end
    end

    context 'required' do
      include_context 'required'

      it 'raises an error' do
        expect do
          filter.default(nil)
        end.to raise_error ActiveInteraction::NoDefaultError
      end
    end

    context 'with an invalid default' do
      before do
        options[:default] = Object.new
      end

      it 'raises an error' do
        expect do
          filter.default(nil)
        end.to raise_error ActiveInteraction::InvalidDefaultError
      end
    end

    context 'with a callable default' do
      include_context 'optional'

      before do
        default = options[:default]
        options[:default] = -> { default }
      end

      it 'returns the default' do
        expect(filter.default(nil)).to eql options[:default].call
      end
    end

    context 'with a callable default that takes an argument' do
      include_context 'optional'

      it 'returns the default' do
        default = options[:default]

        spec = self
        filter # Necessary to bring into scope for lambda.
        options[:default] = lambda do |this|
          spec.expect(this).to be filter
          default
        end

        expect(filter.default(nil)).to be default
      end
    end
  end

  describe '#desc' do
    it 'returns nil' do
      expect(filter.desc).to be_nil
    end

    context 'with a description' do
      let(:desc) { SecureRandom.hex }

      before do
        options[:desc] = desc
      end

      it 'returns the description' do
        expect(filter.desc).to eql desc
      end
    end
  end

  describe '#filters' do
    it 'returns Hash' do
      expect(filter.filters).to be_a Hash
    end
  end

  describe '#default?' do
    context 'optional' do
      include_context 'optional'

      it 'returns true' do
        expect(filter).to be_default
      end
    end

    context 'required' do
      include_context 'required'

      it 'returns false' do
        expect(filter).to_not be_default
      end
    end
  end

  describe '#name' do
    it 'returns the name' do
      expect(filter.name).to eql name
    end
  end

  describe '#options' do
    it 'returns the options' do
      expect(filter.options).to eql options
    end
  end

  describe '#database_column_type' do
    it 'returns a symbol' do
      expect(filter.database_column_type).to be_a Symbol
    end
  end
end
