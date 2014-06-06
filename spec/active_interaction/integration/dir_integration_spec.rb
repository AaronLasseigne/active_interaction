# coding: utf-8

require 'spec_helper'

describe 'DirInteraction' do
  it_behaves_like 'an interaction', :dir, -> { Dir.new('.') }
end
