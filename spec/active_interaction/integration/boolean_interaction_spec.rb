BooleanInteraction = Class.new(TestInteraction) do
  boolean :x
end

RSpec.describe BooleanInteraction do
  it_behaves_like 'an interaction', :boolean, -> { [false, true].sample }

  it "responds to #x?" do
    expect(described_class.new).to respond_to(:x?)
  end
end
