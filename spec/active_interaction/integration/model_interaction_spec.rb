require 'spec_helper'

class ModelInteraction < IntegrationInteraction
  model :a, class: Proc
  model :b, class: Proc, allow_nil: true
end

describe ModelInteraction do
  it_behaves_like 'an integration interaction'

  let(:a) { lambda {} }
  let(:b) { lambda {} }
end
