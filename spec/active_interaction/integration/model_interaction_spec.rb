require 'spec_helper'

describe 'ModelInteraction' do
  it_behaves_like 'an interaction', :model, -> { Proc.new {} }, class: Proc
end
