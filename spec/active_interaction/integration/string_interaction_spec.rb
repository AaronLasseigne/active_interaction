RSpec.describe 'StringInteraction' do
  it_behaves_like 'an interaction', :string, -> { SecureRandom.hex }
end
