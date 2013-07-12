require 'spec_helper'

describe 'TimeInteraction' do
  it_behaves_like 'an interaction', :time, -> { Time.now }
end
