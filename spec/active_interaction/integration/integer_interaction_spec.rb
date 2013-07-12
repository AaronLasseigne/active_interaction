require 'spec_helper'

describe 'IntegerInteraction' do
  it_behaves_like 'an interaction', :integer, -> { rand(1 << 16) }
end
