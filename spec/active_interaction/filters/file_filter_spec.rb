require 'spec_helper'

describe ActiveInteraction::FileFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '#process' do
    let(:result) { filter.process(value, nil) }

    context 'with a File' do
      let(:value) { File.new(__FILE__) }

      it 'returns the File' do
        expect(result.value).to eql value
      end
    end

    context 'with a Tempfile' do
      let(:value) { Tempfile.new(SecureRandom.hex) }

      it 'returns the Tempfile' do
        expect(result.value).to eq value
      end
    end

    context 'with an object that responds to #rewind' do
      let(:value) { double(rewind: nil) } # rubocop:disable RSpec/VerifiedDoubles

      it 'returns the object' do
        expect(result.value).to eq value
      end
    end
  end

  describe '#database_column_type' do
    it 'returns :file' do
      expect(filter.database_column_type).to be :file
    end
  end
end
