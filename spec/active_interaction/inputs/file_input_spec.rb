require 'spec_helper'

describe ActiveInteraction::FileInput, :input do
  let(:name) { SecureRandom.hex.to_sym }
  let(:options) { {} }

  subject(:input) { described_class.new(name, options) }

  describe '#cast' do
    context do
      let(:value) { File.new(__FILE__) }

      it do
        expect(input.cast(value)).to eq value
      end
    end
  end
end
