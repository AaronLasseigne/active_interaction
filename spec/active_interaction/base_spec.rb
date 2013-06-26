require 'active_interaction'

describe ActiveInteraction::Base do
  subject(:base) { described_class.new }

  its(:new_record?) { should be_true  }
  its(:persisted?)  { should be_false }

  describe '#execute' do
    it 'throws a NotImplementedError' do
      expect { base.execute }.to raise_error NotImplementedError
    end
  end

  describe '.run(traits = {})' do
    class SubBase < described_class
      attr_reader :valid

      validates :valid,
        inclusion: {in: [true]}

      def execute
        'Execute!'
      end
    end

    it 'sets the attributes on the return value based on the traits passed' do
      expect(SubBase.run(valid: true).valid).to eq true
    end

    it 'does not allow :response as a trait' do
      expect {
        described_class.run(response: true)
      }.to raise_error ArgumentError
    end

    context 'validations pass' do
      subject(:outcome) { SubBase.run(valid: true) }

      it 'sets `response` to the value of `execute`' do
        expect(outcome.response).to eq 'Execute!'
      end
    end

    context 'validations fail' do
      subject(:outcome) { SubBase.run(valid: false) }

      it 'sets response to nil' do
        expect(outcome.response).to be_nil
      end
    end
  end
end
