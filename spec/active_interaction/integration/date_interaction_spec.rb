RSpec.describe 'DateInteraction' do
  it_behaves_like 'an interaction', :date, -> { Date.today }
end
