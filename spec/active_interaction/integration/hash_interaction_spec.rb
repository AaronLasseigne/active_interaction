# coding: utf-8

require 'spec_helper'

HashInteraction = Class.new(TestInteraction) do
  hash :a do
    hash :x
  end
  hash :b, default: {} do
    hash :x, default: {}
  end
end

describe HashInteraction do
  include_context 'interactions'
  it_behaves_like 'an interaction', :hash, -> { {} }

  context 'with inputs[:a]' do
    let(:a) { { x: {} } }

    before { inputs.merge!(a: a) }

    it 'returns the correct value for :a' do
      expect(result[:a]).to eql a.with_indifferent_access
    end

    it 'returns the correct value for :b' do
      expect(result[:b]).to eql('x' => {})
    end
  end
end
