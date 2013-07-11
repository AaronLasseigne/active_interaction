require 'spec_helper'

describe ActiveInteraction::FileFilter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '.prepare(key, value, options = {}, &block)' do
    context 'with a File' do
      let(:value) { File.open(__FILE__) }

      it 'returns the File' do
        expect(result).to equal(value)
      end
    end

    context 'with a Tempfile' do
      let(:value) { Tempfile.open(__FILE__) }

      it 'returns the Tempfile' do
        expect(result).to equal(value)
      end
    end

    context 'with a model that responds to `tempfile`' do
      let(:value) { double(tempfile: Tempfile.open(__FILE__)) }

      it 'returns the Tempfile' do
        expect(result).to equal(value.tempfile)
      end
    end
  end
end
