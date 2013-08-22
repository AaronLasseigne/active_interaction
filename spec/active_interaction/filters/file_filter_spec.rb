require 'spec_helper'

shared_examples_for 'valid file values' do |method|
  context 'with a file' do
    let(:value) { File.open(__FILE__) }

    it 'returns the File' do
      expect(send(method)).to equal value
    end
  end

  context 'with a Tempfile' do
    let(:value) { Tempfile.new(SecureRandom.hex) }

    it 'returns the Tempfile' do
      expect(send(method)).to equal value
    end
  end

  context 'with a object that responds to `tempfile`' do
    let(:value) { double(tempfile: Tempfile.new(SecureRandom.hex)) }

    it 'returns the Tempfile' do
      expect(send(method)).to equal value.tempfile
    end
  end
end

describe ActiveInteraction::FileFilter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '.prepare(key, value, options = {}, &block)' do
    include_examples 'valid file values', :prepare
  end

  describe '.default(key, value, options = {}, &block)' do
    include_examples 'valid file values', :default
  end
end
