# coding: utf-8

require 'spec_helper'

describe 'EnumeratorInteraction' do
  it_behaves_like 'an interaction', :enumerator, -> { Enumerator.new { |_| } }
end
