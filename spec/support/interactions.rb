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

shared_examples_for 'an interaction' do |type, generator, adjust_output = nil, **filter_options|
  include_context 'interactions'

  let(:described_class) do
    Class.new(TestInteraction) do
      public_send(type, :required, filter_options)
      public_send(type, :optional,
        filter_options.merge(
          default: nil
        )
      )
      public_send(type, :default,
        filter_options.merge(
          default: generator.call
        )
      )
      public_send(type, :defaults1, :defaults2,
        filter_options.merge(
          default: generator.call
        )
      )
      public_send(type, :defaults3,
        filter_options.merge(
          default: -> { required }
        )
      )
    end
  end

  context 'with an invalid lazy default' do
    let(:described_class) do
      Class.new(TestInteraction) do
        public_send(type, :default,
          filter_options.merge(default: -> { Object.new })
        )
      end
    end

    it 'raises an error' do
      expect { outcome }.to raise_error ActiveInteraction::InvalidDefaultError
    end
  end

  context 'without required inputs' do
    it 'is invalid' do
      expect(outcome).to be_invalid
    end
  end

  context 'with inputs[:required]' do
    let(:required) { generator.call }

    before { inputs[:required] = required }

    it 'is valid' do
      expect(outcome).to be_valid
    end

    it 'returns the correct value for :required' do
      expect(result[:required]).to eql(adjust_output ? adjust_output.call(required) : required)
    end

    it 'returns nil for :optional' do
      expect(result[:optional]).to be_nil
    end

    it 'does not return nil for :default' do
      expect(result[:default]).to_not be_nil
    end

    it 'does not return nil for :default when given nil' do
      inputs[:default] = nil
      expect(result[:default]).to_not be_nil
    end

    it 'does not return nil for :defaults1' do
      expect(result[:defaults1]).to_not be_nil
    end

    it 'does not return nil for :defaults2' do
      expect(result[:defaults2]).to_not be_nil
    end

    it 'evaluates :defaults3 in the interaction binding' do
      expect(result[:defaults3]).to eql result[:required]
    end

    context 'with inputs[:optional]' do
      let(:optional) { generator.call }

      before { inputs[:optional] = optional }

      it 'returns the correct value for :optional' do
        expect(result[:optional]).to eql(adjust_output ? adjust_output.call(optional) : optional)
      end
    end

    context 'with inputs[:default]' do
      let(:default) { generator.call }

      before { inputs[:default] = default }

      it 'returns the correct value for :default' do
        expect(result[:default]).to eql(adjust_output ? adjust_output.call(default) : default)
      end
    end
  end
end
