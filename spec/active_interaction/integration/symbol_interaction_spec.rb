# coding: utf-8

require 'spec_helper'

describe 'SymbolInteraction' do
  it_behaves_like 'an interaction', :symbol, -> { SecureRandom.hex.to_sym }
end
