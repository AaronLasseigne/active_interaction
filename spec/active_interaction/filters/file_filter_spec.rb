require 'spec_helper'

describe ActiveInteraction::FileFilter, :filter do
  let(:name) { SecureRandom.hex.to_sym }
  let(:options) { {} }

  subject(:filter) { described_class.new(name, options) }

  describe '#cast' do
    context do
      let(:value) { File.new(__FILE__) }

      it do
        expect(filter.cast(value)).to eq value
      end
    end
  end
end
