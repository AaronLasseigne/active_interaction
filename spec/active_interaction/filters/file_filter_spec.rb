# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::FileFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '#cast' do
    context 'with a File' do
      let(:value) { File.new(__FILE__) }

      it 'returns the File' do
        expect(filter.cast(value)).to eql value
      end
    end

    context 'with a Tempfile' do
      let(:value) { Tempfile.new(SecureRandom.hex) }

      it 'returns the Tempfile' do
        expect(filter.cast(value)).to eq value
      end
    end

    context 'with an object that responds to #tempfile' do
      let(:value) { double(tempfile: Tempfile.new(SecureRandom.hex)) }

      it 'returns the Tempfile' do
        expect(filter.cast(value)).to eq value.tempfile
      end
    end
  end
end
