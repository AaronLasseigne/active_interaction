# coding: utf-8

require 'spec_helper'

describe 'RangeInteraction' do
  it_behaves_like 'an interaction', :range, -> { Range.new(0, 0) }
end
