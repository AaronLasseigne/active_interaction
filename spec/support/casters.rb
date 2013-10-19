shared_context 'casters' do
  let(:key) { SecureRandom.hex }
  let(:value) { nil }
  let(:options) { {} }
  let(:block) { Proc.new {} }
  subject(:result) { described_class.prepare(key, value, options, &block) }
end

shared_examples_for 'a caster' do
  include_context 'casters'

  context '.prepare(key, value, options = {}, &block)' do
    context 'with nil' do
      it 'raises an error' do
        expect { result }.to raise_error ActiveInteraction::MissingValue
      end
    end

    context 'with anything else' do
      let(:value) { Object.new }

      it 'raises an error' do
        expect { result }.to raise_error ActiveInteraction::InvalidValue
      end
    end

    context 'optional' do
      before { options.merge!(allow_nil: true) }

      context 'with nil' do
        it 'returns nil' do
          expect(result).to be_nil
        end
      end
    end
  end
end
