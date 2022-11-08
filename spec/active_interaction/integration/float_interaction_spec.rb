RSpec.describe 'FloatInteraction' do
  it_behaves_like 'an interaction', :float, -> { rand }
end
