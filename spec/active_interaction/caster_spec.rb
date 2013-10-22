require 'spec_helper'

module ActiveInteraction
  TestCaster = Class.new(Caster)
  class TestFilter < Filter; end
end

describe ActiveInteraction::Caster do
  include_context 'casters', ActiveInteraction::TestFilter

  describe '.cast(filter, value)' do
    let(:result) { described_class.cast(filter, value) }

    context 'with a valid type' do
      it 'calls `prepare` on the proper Caster type' do
        allow(ActiveInteraction::TestCaster).to receive(:prepare)
        result
        expect(ActiveInteraction::TestCaster).to have_received(:prepare).once.with(filter, value)
      end
    end

    context 'with an invalid type' do
      let(:filter) { Object.new }

      it 'raises an error' do
        expect { result }.to raise_error NameError
      end
    end
  end
end
