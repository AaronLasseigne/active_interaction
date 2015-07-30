# coding: utf-8

require 'spec_helper'

ArrayInteraction = Class.new(TestInteraction) do
  array :a do
    array
  end
  array :b, default: [[]] do
    array
  end
end

describe ArrayInteraction do
  include_context 'interactions'
  it_behaves_like 'an interaction', :array, -> { [] }

  context 'with inputs[:a]' do
    let(:a) { [[]] }

    before { inputs.merge!(a: a) }

    it 'returns the correct value for :a' do
      expect(result[:a]).to eql a
    end

    it 'returns the correct value for :b' do
      expect(result[:b]).to eql [[]]
    end
  end

  context 'with an invalid default' do
    it 'raises an error' do
      expect do
        Class.new(ActiveInteraction::Base) do
          array :a, default: Object.new
        end
      end.to raise_error ActiveInteraction::InvalidDefaultError
    end
  end

  context 'with an invalid default as a proc' do
    it 'does not raise an error' do
      expect do
        Class.new(ActiveInteraction::Base) do
          array :a, default: -> { Object.new }
        end
      end.to_not raise_error
    end
  end

  context 'with an invalid nested default' do
    it 'raises an error' do
      expect do
        Class.new(ActiveInteraction::Base) do
          array :a, default: [Object.new] do
            array
          end
        end
      end.to raise_error ActiveInteraction::InvalidDefaultError
    end
  end
end
