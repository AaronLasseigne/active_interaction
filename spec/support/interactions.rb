shared_context 'interactions' do
  let(:options) { {} }
  let(:outcome) { described_class.run(options) }
  let(:result) { outcome.result }
end

shared_examples_for 'an interaction' do |type, generator, filter_options = {}|
  include_context 'interactions'

  let(:described_class) do
    Class.new(ActiveInteraction::Base) do
      send(type, :required, filter_options)
      send(type, :optional, filter_options.merge(allow_nil: true))
      send(type, :default, filter_options.merge(default: generator.call))
      send(type, :nil_default,
           filter_options.merge(allow_nil: true, default: nil))
      send(type, :multi_default_1, :multi_default_2, filter_options.merge(default: generator.call))

      def execute
        {
          required: required,
          optional: optional,
          default: default,
          nil_default: nil_default
        }
      end
    end
  end

  context 'without required options' do
    it 'is invalid' do
      expect(outcome).to be_invalid
    end
  end

  context 'with options[:required]' do
    let(:required) { generator.call }

    before { options.merge!(required: required) }

    it 'is valid' do
      expect(outcome).to be_valid
    end

    it 'returns the correct value for :required' do
      expect(result[:required]).to eq required
    end

    it 'returns nil for :optional' do
      expect(result[:optional]).to be_nil
    end

    it 'does not return nil for :default' do
      expect(result[:default]).to_not be_nil
    end

    it 'returns nil for :nil_default' do
      expect(result[:nil_default]).to be_nil
    end

    context 'with options[:optional]' do
      let(:optional) { generator.call }

      before { options.merge!(optional: optional) }

      it 'returns the correct value for :optional' do
        expect(result[:optional]).to eq optional
      end
    end

    context 'with options[:default]' do
      let(:default) { generator.call }

      before { options.merge!(default: default) }

      it 'returns the correct value for :default' do
        expect(result[:default]).to eq default
      end

      it 'sets the default on multiple attributes' do
        expect(outcome).to be_valid
      end
    end
  end
end
