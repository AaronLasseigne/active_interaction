require 'spec_helper'

describe 'DateInteraction' do
  it_behaves_like 'an interaction', :date, -> { Date.today }
end
