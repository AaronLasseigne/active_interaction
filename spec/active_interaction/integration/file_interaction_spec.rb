require 'spec_helper'

class FileInteraction < IntegrationInteraction
  file :a
  file :b, allow_nil: true
end

describe FileInteraction do
  it_behaves_like 'an integration interaction'

  let(:a) { File.open(__FILE__) }
  let(:b) { File.open(__FILE__) }
end
