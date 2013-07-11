require 'spec_helper'

describe ActiveInteraction::FileFilter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '.prepare(key, value, options = {}, &block)' do
    context 'with a File' do
      let(:value) { File.open(__FILE__) }

      it 'returns the File' do
        expect(result).to eql(value)
      end
    end
  end
end
