# coding: utf-8

require 'spec_helper'

describe 'RegexpInteraction' do
  it_behaves_like 'an interaction', :regexp, -> { Regexp.new('') }
end
