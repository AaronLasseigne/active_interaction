shared_context 'filters' do
  let(:name) { nil }
  let(:options) { {} }
  subject(:result) { described_class.new(name, options) }
end

shared_examples_for 'a filter' do
  include_context 'filters'

  its(:name) { should equal name }
  its(:options) { should eq options }
end

shared_context 'filters with blocks' do
  include_context 'filters'

  let(:block) { Proc.new {} }
  subject(:result) { described_class.new(name, options, &block) }
end

shared_examples_for 'a filter with a block' do
  include_context 'filters with blocks'

  it_behaves_like 'a filter'
end
