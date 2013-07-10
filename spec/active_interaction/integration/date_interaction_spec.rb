require 'spec_helper'

class DateInteraction < IntegrationInteraction
  date :a
  date :b, allow_nil: true
end

describe DateInteraction do
  it_behaves_like 'an integration interaction'

  let(:a) { Date.today }
  let(:b) { Date.new }
end
