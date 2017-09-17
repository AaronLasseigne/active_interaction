require 'spec_helper'

describe 'StringInteraction' do
  it_behaves_like 'an interaction', :string, -> { SecureRandom.hex }
end
