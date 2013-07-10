require 'spec_helper'

class DateTimeInteraction < IntegrationInteraction
  date_time :a
  date_time :b, allow_nil: true
end

describe DateTimeInteraction do
  it_behaves_like 'an integration interaction'

  let(:a) { DateTime.now }
  let(:b) { DateTime.new }
end
