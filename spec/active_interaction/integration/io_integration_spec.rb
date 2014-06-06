# coding: utf-8

require 'spec_helper'

describe 'IOInteraction' do
  it_behaves_like 'an interaction', :io, -> { STDIN }
end
