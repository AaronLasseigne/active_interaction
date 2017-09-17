require 'spec_helper'

describe 'DateTimeInteraction' do
  it_behaves_like 'an interaction', :date_time, -> { DateTime.now }
end
