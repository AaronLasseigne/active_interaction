require 'spec_helper'

describe ActiveInteraction::StringFilter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '.prepare(key, value, options = {}, &block)' do
    context 'with a String' do
      let(:value) { SecureRandom.hex }

      it 'returns the String' do
        expect(result).to eql value
      end
    end
  end
end
