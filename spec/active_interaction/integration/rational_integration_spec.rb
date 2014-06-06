# coding: utf-8

require 'spec_helper'

describe 'RationalInteraction' do
  it_behaves_like 'an interaction', :rational, -> { Rational(0) }
end
