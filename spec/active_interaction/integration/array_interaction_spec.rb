require 'spec_helper'

class ArrayInteraction < ActiveInteraction::Base
  array :a do
    array
  end

  def execute
    a
  end
end

describe ArrayInteraction do
  include_context 'interactions'
  it_behaves_like 'an interaction', :array, -> { [] }

  it do
    a = [[]]
    options.merge!(a: a)
    expect(result).to eq a
  end
end
