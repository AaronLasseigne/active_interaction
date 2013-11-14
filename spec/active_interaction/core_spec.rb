require 'spec_helper'

describe ActiveInteraction::Core do
  let(:model) do
    Class.new do
      include ActiveInteraction::Core
    end
  end

  subject(:instance) { model.new }

  describe '#desc' do
    let(:desc) { SecureRandom.hex }

    it 'returns nil' do
      expect(instance.desc).to be_nil
    end

    it 'returns the description' do
      expect(instance.desc(desc)).to eq desc
    end

    it 'saves the description' do
      instance.desc(desc)
      expect(instance.desc).to eq desc
    end
  end

  describe '#run!' do
    let(:errors) { double(full_messages: []) }
    let(:outcome) { double(errors: errors, result: result) }
    let(:result) { double }

    before do
      allow(instance).to receive(:run).and_return(outcome)
    end

    shared_examples '#run!' do
      let(:options) { double }

      it 'calls #run' do
        expect(instance).to receive(:run).once.with(options)
        instance.run!(options) rescue nil
      end
    end

    context 'with invalid outcome' do
      include_examples '#run!'

      before do
        allow(outcome).to receive(:valid?).and_return(false)
      end

      it 'raises an error' do
        expect {
          instance.run!
        }.to raise_error ActiveInteraction::InvalidInteractionError
      end
    end

    context 'with valid outcome' do
      include_examples '#run!'

      before do
        allow(outcome).to receive(:valid?).and_return(true)
      end

      it 'returns the result' do
        expect(instance.run!).to eq result
      end
    end
  end

  describe '#transaction' do
    context 'without ActiveRecord' do
      it 'returns nil' do
        expect(instance.send(:transaction)).to be_nil
      end

      it 'yields' do
        expect { |b| instance.send(:transaction, &b) }.to yield_control
      end
    end

    context 'with ActiveRecord' do
      before do
        ActiveRecord = Class.new
        ActiveRecord::Base = double
        allow(ActiveRecord::Base).to receive(:transaction)
      end

      after do
        Object.send(:remove_const, :ActiveRecord)
      end

      it 'returns nil' do
        expect(instance.send(:transaction)).to be_nil
      end

      it 'calls ActiveRecord::Base#transaction' do
        block = Proc.new {}
        expect(ActiveRecord::Base).to receive(:transaction).once.with(no_args)
        instance.send(:transaction, &block)
      end

      it 'calls ActiveRecord::Base#transaction' do
        args = [:a, :b, :c]
        block = Proc.new {}
        expect(ActiveRecord::Base).to receive(:transaction).once.with(*args)
        instance.send(:transaction, *args, &block)
      end
    end
  end
end
