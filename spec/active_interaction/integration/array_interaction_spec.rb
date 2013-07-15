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

  context 'with an invalidly nested default' do
    it 'raises an error' do
      expect {
        klass = Class.new(ActiveInteraction::Base) do
          array :a do
            array default: []
          end
        end
        # TODO: Fail when defining class, not running it.
        klass.run(a: [])
      }.to raise_error ArgumentError
    end
  end
end
