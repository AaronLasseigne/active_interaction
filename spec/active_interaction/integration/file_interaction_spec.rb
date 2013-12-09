# coding: utf-8

require 'spec_helper'

describe 'FileInteraction' do
  it_behaves_like 'an interaction', :file, -> { File.open(__FILE__) }
end
