require 'spec_helper'

class HashInteraction < ActiveInteraction::Base
  hash :a do
    hash :b
  end

  def execute
    a
  end
end

describe HashInteraction do
  include_context 'interactions'
  it_behaves_like 'an interaction', :hash, -> { {} }

  it do
    a = { 'b' => {} }
    options.merge!(a: a)
    expect(result).to eq a
  end
end
