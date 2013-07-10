require 'spec_helper'

class StringInteraction < IntegrationInteraction
  string :a
  string :b, allow_nil: true
end

describe StringInteraction do
  it_behaves_like 'an integration interaction'

  let(:a) { SecureRandom.hex }
  let(:b) { SecureRandom.hex }
end
