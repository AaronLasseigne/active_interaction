shared_context 'interactions' do
  let(:options) { {} }
  let(:outcome) { described_class.run(options) }
  let(:result) { outcome.result }
end

shared_examples_for 'an interaction' do |type, value_lambda, filter_options = {}|
  include_context 'interactions'

  let(:described_class) do
    Class.new(ActiveInteraction::Base) do
      send(type, :a, filter_options)
      send(type, :b, filter_options.merge(allow_nil: true))
      send(type, :c, filter_options.merge(default: value_lambda.call))
      send(type, :d, filter_options.merge(allow_nil: true, default: nil))

      def execute
        { a: a, b: b, c: c, d: d }
      end
    end
  end

  context 'without required options' do
    it 'is invalid' do
      expect(outcome).to be_invalid
    end
  end

  context 'with required options' do
    let(:a) { value_lambda.call }

    before { options.merge!(a: a) }

    it 'is valid' do
      expect(outcome).to be_valid
    end

    it 'returns the correct value for :a' do
      expect(result[:a]).to eq a
    end

    it 'returns nil for :b' do
      expect(result[:b]).to be_nil
    end

    it 'does not return nil for :c' do
      expect(result[:c]).to_not be_nil
    end

    it 'returns nil for :d' do
      expect(result[:d]).to be_nil
    end

    context 'with optional option :b' do
      let(:b) { value_lambda.call }

      before { options.merge!(b: b) }

      it 'returns the correct value for :b' do
        expect(result[:b]).to eq b
      end
    end
  end
end
