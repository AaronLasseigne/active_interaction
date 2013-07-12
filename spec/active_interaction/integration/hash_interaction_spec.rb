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
end
