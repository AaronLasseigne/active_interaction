shared_context 'filters' do
  let(:key) { SecureRandom.hex }
  let(:value) { nil }
  let(:options) { {} }
  let(:block) { Proc.new {} }
  let(:prepare) { described_class.prepare(key, value, options, &block) }
  let(:default) { described_class.default(key, value, options, &block) }
end

shared_examples_for 'a filter' do
  include_context 'filters'

  shared_examples_for 'raising errors' do |method, error|
    context 'with nil' do
      it 'raises an error' do
        expect { send(method) }.to raise_error ActiveInteraction::MissingValue
      end
    end

    context 'with anything else' do
      let(:value) { Object.new }

      it 'raises an error' do
        expect { send(method) }.to raise_error error
      end
    end
  end

  describe '.prepare(key, value, options = {}, &block)' do
    include_examples 'raising errors', :prepare, ActiveInteraction::InvalidValue

    context 'optional' do
      before { options.merge!(allow_nil: true) }

      context 'with nil' do
        it 'returns nil' do
          expect(prepare).to be_nil
        end
      end
    end
  end

  describe '.default(key, value, options = {}, &block)' do
    include_examples 'raising errors', :default, ActiveInteraction::InvalidDefaultValue
  end
end
