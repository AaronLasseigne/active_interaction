shared_context 'filters' do
  let(:name) { nil }
  let(:options) { {} }
  let(:block) { Proc.new {} }
  subject(:result) { described_class.new(name, options, &block) }
end

shared_examples_for 'a filter' do
  include_context 'filters'

  its(:name) { should equal name }
  its(:options) { should eq options }
  its(:block) { should equal block }
end
