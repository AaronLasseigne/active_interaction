require 'spec_helper'

describe ActiveInteraction::SymbolCaster do
  include_context 'casters', ActiveInteraction::SymbolFilter
  it_behaves_like 'a caster', ActiveInteraction::SymbolFilter

  describe '.prepare(filter, value)' do
    context 'with a Symbol' do
      let(:value) { SecureRandom.hex.to_sym }

      it 'returns the Symbol' do
        expect(result).to eql value
      end
    end

    context 'with a String' do
      let(:value) { SecureRandom.hex }

      it 'returns the String as a Symbol' do
        expect(result).to eql value.to_sym
      end
    end
  end
end
