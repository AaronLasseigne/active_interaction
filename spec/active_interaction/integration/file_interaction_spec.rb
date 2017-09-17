require 'spec_helper'
require 'action_dispatch'

FileInteraction = Class.new(TestInteraction) do
  file :a
end

describe FileInteraction do
  include_context 'interactions'
  it_behaves_like 'an interaction', :file, -> { File.open(__FILE__) }

  it 'works with an uploaded file' do
    file = File.open(__FILE__)
    uploaded_file = ActionDispatch::Http::UploadedFile.new(tempfile: file)
    inputs[:a] = uploaded_file
    expect(outcome).to be_valid
  end
end
