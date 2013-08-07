require 'spec_helper'

class ArrayInteraction < ActiveInteraction::Base
  array :a do
    array
  end
  array :b, default: [[]] do
    array
  end

  def execute
    { a: a, b: b }
  end
end

describe ArrayInteraction do
  include_context 'interactions'
  it_behaves_like 'an interaction', :array, -> { [] }

  context 'with options[:a]' do
    let(:a) { [[]] }

    before { options.merge!(a: a) }

    it 'returns the correct value for :a' do
      expect(result[:a]).to eq a
    end

    it 'returns the correct value for :b' do
      expect(result[:b]).to eq [[]]
    end
  end

  context 'with an invalid default' do
    it 'raises an error' do
      expect {
        Class.new(ActiveInteraction::Base) do
          array :a, default: Object.new
        end
      }.to raise_error ActiveInteraction::InvalidDefaultValue
    end
  end

  context 'with an invalid nested default' do
    it 'raises an error' do
      expect {
        Class.new(ActiveInteraction::Base) do
          array :a, default: [Object.new] do
            array
          end
        end
      }.to raise_error ActiveInteraction::InvalidDefaultValue
    end
  end

  context 'with a validly nested default' do
    let(:described_class) do
      Class.new(ActiveInteraction::Base) do
        array :a do
          array default: [rand]
        end
        def execute; a end
      end
    end
    let(:options) { { a: [] } }

    it 'does not raise an error' do
      expect { described_class.run(options) }.to_not raise_error
    end

    it 'ignores the nested default value' do
      expect(described_class.run!(options)).to eq options[:a]
    end
  end
end
