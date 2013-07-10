require 'spec_helper'

class FloatInteraction < IntegrationInteraction
  float :a
  float :b, allow_nil: true
end

describe FloatInteraction do
  it_behaves_like 'an integration interaction'

  let(:a) { rand }
  let(:b) { rand }
end
