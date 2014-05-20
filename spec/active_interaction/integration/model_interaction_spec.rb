# coding: utf-8

require 'spec_helper'

describe 'ModelInteraction' do
  it_behaves_like 'an interaction', :model, -> { // }, class: Regexp
end
