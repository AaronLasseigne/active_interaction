require 'spec_helper'

class TimeInteraction < IntegrationInteraction
  time :a
  time :b, allow_nil: true
end

describe TimeInteraction do
  it_behaves_like 'an integration interaction'

  let(:a) { Time.now }
  let(:b) { Time.new }
end
