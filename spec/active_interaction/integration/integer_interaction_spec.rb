require 'spec_helper'

class IntegerInteraction < IntegrationInteraction
  integer :a
  integer :b, allow_nil: true
end

describe IntegerInteraction do
  it_behaves_like 'an integration interaction'

  let(:a) { rand(1 << 16) }
  let(:b) { rand(1 << 16) }
end
