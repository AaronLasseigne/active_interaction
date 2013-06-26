require 'active_interaction'

shared_examples 'validations pass' do |method|
  context 'validations pass' do
    subject(:outcome) { SubBase.send(method, valid: true) }

    it 'sets `response` to the value of `execute`' do
      expect(outcome.response).to eq 'Execute!'
    end
  end
end

describe ActiveInteraction::Base do
  subject(:base) { described_class.new }

  class SubBase < described_class
    attr_reader :valid

    validates :valid,
      inclusion: {in: [true]}

    def execute
      'Execute!'
    end
  end

  describe '.new(options = {})' do
    it 'sets the attributes on the return value based on the options passed' do
      expect(SubBase.new(valid: true).valid).to eq true
    end

    it 'does not allow :response as a option' do
      expect {
        SubBase.new(response: true)
      }.to raise_error ArgumentError
    end
  end

  describe '.run(options = {})' do
    it_behaves_like 'validations pass', :run

    context 'validations fail' do
      subject(:outcome) { SubBase.run(valid: false) }

      it 'sets response to nil' do
        expect(outcome.response).to be_nil
      end
    end
  end

  describe '.run!(options = {})' do
    it_behaves_like 'validations pass', :run!

    context 'validations fail' do
      it 'throws an error' do
        expect {
          SubBase.run!(valid: false)
        }.to raise_error ActiveInteraction::InteractionInvalid
      end
    end
  end

  its(:new_record?) { should be_true  }
  its(:persisted?)  { should be_false }

  describe '#execute' do
    it 'throws a NotImplementedError' do
      expect { base.execute }.to raise_error NotImplementedError
    end
  end
end
