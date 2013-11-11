shared_context 'casters' do |filter_class|
  let(:value) { nil }
  let(:name) { SecureRandom.hex }
  let(:options) { {} }
  let(:block) { Proc.new {} }
  let(:filter) { filter_class.new(name, options, &block)}
  subject(:result) { described_class.prepare(filter, value) }
end

shared_examples_for 'a caster' do |filter_class|
  include_context 'casters', filter_class

  context '.prepare(filter, value)' do
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
