shared_context 'interactions' do
  let(:options) { {} }
  let(:outcome) { described_class.run(options) }
  let(:result) { outcome.result }
end

class IntegrationInteraction < ActiveInteraction::Base
  def execute
    b || a
  end
end

shared_examples_for 'an integration interaction' do
  include_context 'interactions'

  it 'is invalid without required options' do
    expect(outcome).to be_invalid
  end

  context 'with required option "a"' do
    before { options.merge!(a: a) }

    it 'returns the correct value' do
      expect(result).to eq a
    end

    context 'with optional option "b"' do
      before { options.merge!(b: b) }

      it 'returns the correct value' do
        expect(result).to eq b
      end
    end
  end
end
