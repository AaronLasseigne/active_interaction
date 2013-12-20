# coding: utf-8

TestInteraction = Class.new(ActiveInteraction::Base) do
  def self.name
    SecureRandom.hex
  end

  def execute
    inputs
  end
end

shared_context 'interactions' do
  let(:inputs) { {} }
  let(:outcome) { described_class.run(inputs) }
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
    end
  end

  context 'without required inputs' do
    it 'is invalid' do
      expect(outcome).to be_invalid
    end
  end

  context 'with inputs[:required]' do
    let(:required) { generator.call }

    before { inputs.merge!(required: required) }

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
      inputs.merge!(default: nil)
      expect(result[:default]).to_not be_nil
    end

    it 'does not return nil for :defaults_1' do
      expect(result[:defaults_1]).to_not be_nil
    end

    it 'does not return nil for :defaults_2' do
      expect(result[:defaults_2]).to_not be_nil
    end

    context 'with inputs[:optional]' do
      let(:optional) { generator.call }

      before { inputs.merge!(optional: optional) }

      it 'returns the correct value for :optional' do
        expect(result[:optional]).to eq optional
      end
    end

    context 'with inputs[:default]' do
      let(:default) { generator.call }

      before { inputs.merge!(default: default) }

      it 'returns the correct value for :default' do
        expect(result[:default]).to eq default
      end
    end
  end
end
