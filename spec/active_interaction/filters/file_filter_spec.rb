require 'spec_helper'

describe ActiveInteraction::FileFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '#cast' do
    let(:result) { filter.cast(value, nil) }

    context 'with a File' do
      let(:value) { File.new(__FILE__) }

      it 'returns the File' do
        expect(result).to eql value
      end
    end

    context 'with a Tempfile' do
      let(:value) { Tempfile.new(SecureRandom.hex) }

      it 'returns the Tempfile' do
        expect(result).to eq value
      end
    end

    context 'with an object that responds to #rewind' do
      let(:value) { double(rewind: nil) }

      it 'returns the object' do
        expect(result).to eq value
      end
    end
  end

  describe '#database_column_type' do
    it 'returns :file' do
      expect(filter.database_column_type).to eql :file
    end
  end
end
