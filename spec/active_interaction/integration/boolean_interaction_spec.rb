require 'spec_helper'

describe 'BooleanInteraction' do
  it_behaves_like 'an interaction', :boolean, -> { [false, true].sample }
end
