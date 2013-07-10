require 'spec_helper'

class BooleanInteraction < IntegrationInteraction
  boolean :a
  boolean :b, allow_nil: true
end

describe BooleanInteraction do
  it_behaves_like 'an integration interaction'

  let(:a) { false }
  let(:b) { true }
end
