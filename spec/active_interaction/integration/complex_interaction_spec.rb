# coding: utf-8

require 'spec_helper'

describe 'ComplexInteraction' do
  it_behaves_like 'an interaction', :complex, -> { Complex(rand) }
end
