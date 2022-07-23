require 'spec_helper'

describe 'RecordIntegration' do
  it_behaves_like 'an interaction', :record, -> { Encoding::US_ASCII }, class: Encoding
end
