require 'spec_helper'

class HashInteraction < ActiveInteraction::Base
  hash :a do
    hash :x
  end
  hash :b, default: { x: {} } do
    hash :x
  end

  def execute
    { a: a, b: b }
  end
end

describe HashInteraction do
  include_context 'interactions'
  it_behaves_like 'an interaction', :hash, -> { {} }

  context 'with options[:a]' do
    let(:a) { { 'x' => {} } }

    before { options.merge!(a: a) }

    it 'returns the correct value for :a' do
      expect(result[:a]).to eq a
    end

    it 'returns the correct value for :b' do
      expect(result[:b]).to eq(x: {})
    end
  end

  context 'with an invalid default' do
    it 'raises an error' do
      expect {
        Class.new(ActiveInteraction::Base) do
          hash :a, default: Object.new
        end
      }.to raise_error ActiveInteraction::InvalidDefaultValue
    end
  end

  context 'with an invalid nested default' do
    it 'raises an error' do
      expect {
        Class.new(ActiveInteraction::Base) do
          hash :a, default: { x: Object.new } do
            hash :x
          end
        end
      }.to raise_error ActiveInteraction::InvalidDefaultValue
    end
  end

  context 'with an invalidly nested default' do
    it 'raises an error' do
      expect {
        klass = Class.new(ActiveInteraction::Base) do
          hash :a do
            hash :x, default: {}
          end
        end
        # TODO: We should fail when defining the class, not when trying to run it.
        klass.run(a: {})
      }.to raise_error ArgumentError
    end
  end
end
