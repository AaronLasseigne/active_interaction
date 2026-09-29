RSpec.describe ActiveInteraction::Filter, :filter do
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

  describe '#default' do
    subject(:filter) { ActiveInteraction::IntegerFilter.new(:test, default: default) }

    context 'when it is a value' do
      let(:default) { 1 }

      it 'returns the default' do
        expect(filter.default).to be 1
      end
    end

    context 'when it is a proc' do
      let(:default) { -> { i + 1 } }

      it 'returns the default' do
        expect(filter.default(double(i: 0))).to be 1 # rubocop:disable RSpec/VerifiedDoubles
        expect(filter.default(double(i: 1))).to be 2 # rubocop:disable RSpec/VerifiedDoubles
      end
    end

    context 'when it converts to nil' do
      let(:default) { '' }

      it 'returns nil instead of asking for the default again' do
        expect(filter.default).to be_nil
      end
    end

    context 'when a proc returns a value that converts to nil' do
      let(:default) { -> { '' } }

      it 'returns nil instead of asking for the default again' do
        expect(filter.default).to be_nil
      end
    end
  end

  # A blank string is treated as "not given", which for an input means
  # "fall back to the default". A default has nothing to fall back to, so it
  # must resolve to nil rather than ask for itself again.
  describe 'a default that converts to nil' do
    %i[
      boolean decimal float integer record
      date date_time time
    ].each do |slug|
      it "does not recurse for #{slug}" do
        options = { default: -> { '' } }
        options[:class] = Symbol if slug == :record # a String must not match
        filter = described_class.factory(slug).new(:test, **options)

        expect { filter.default }.to_not raise_error
        expect(filter.default).to be_nil
      end
    end
  end
end
