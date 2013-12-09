# coding: utf-8

TestInteraction = Class.new(ActiveInteraction::Base) do
  def self.name
    SecureRandom.hex
  end

  def execute
  end
end

shared_context 'interactions' do
  let(:options) { {} }
  let(:outcome) { described_class.run(options) }
  let(:result) { outcome.result }
end

shared_examples_for 'an interaction' do |type, generator, filter_options = {}|
  include_context 'interactions'

  let(:described_class) do
    Class.new(TestInteraction) do
      send(type, :required, filter_options)
      send(type, :optional, filter_options.merge(default: nil))
      send(type, :default, filter_options.merge(default: generator.call))
      send(type, :defaults_1, :defaults_2,
           filter_options.merge(default: generator.call))

      def execute
        {
          required: required,
          optional: optional,
          default: default,
          defaults_1: defaults_1,
          defaults_2: defaults_2
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

    it 'does not return nil for :default when given nil' do
      options.merge!(default: nil)
      expect(result[:default]).to_not be_nil
    end

    it 'does not return nil for :defaults_1' do
      expect(result[:defaults_1]).to_not be_nil
    end

    it 'does not return nil for :defaults_2' do
      expect(result[:defaults_2]).to_not be_nil
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
    end
  end
end
