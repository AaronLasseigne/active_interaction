require 'spec_helper'

describe ActiveInteraction::Base do
  let(:options) { {} }
  subject(:interaction) { described_class.new(options) }

  class InteractionWithAttribute < described_class
    attr_reader :thing

    validates :thing, presence: true

    def execute
      thing
    end
  end

  class InteractionWithFilter < described_class
    float :thing

    def execute
      thing
    end
  end

  class InteractionWithFilters < described_class
    float :thing1, :thing2

    def execute; end
  end

  describe '.new(options = {})' do
    it 'does not allow :result as an option' do
      options.merge!(result: nil)
      expect { interaction }.to raise_error ArgumentError
    end

    it 'does not allow "result" as an option' do
      options.merge!('result' => nil)
      expect { interaction }.to raise_error ArgumentError
    end

    describe InteractionWithAttribute do
      let(:described_class) { InteractionWithAttribute }
      let(:thing) { SecureRandom.hex }

      context 'failing validations' do
        before { options.merge!(thing: nil) }

        it 'returns an invalid outcome' do
          expect(interaction).to be_invalid
        end
      end

      context 'passing validations' do
        before { options.merge!(thing: thing) }

        it 'returns a valid outcome' do
          expect(interaction).to be_valid
        end

        it 'sets the attribute' do
          expect(interaction.thing).to eq thing
        end
      end
    end
  end

  describe '.method_missing(filter_type, *args, &block)' do
    it 'raises an error for invalid filter types' do
      expect {
        class InteractionWithInvalidFilter < described_class
          not_a_valid_filter_type :thing
          def execute; end
        end
      }.to raise_error NoMethodError
    end

    describe InteractionWithFilter do
      let(:described_class) { InteractionWithFilter }

      it 'adds an attr_reader' do
        expect(interaction).to respond_to :thing
      end

      it 'adds an attr_writer' do
        expect(interaction).to respond_to :thing=
      end
    end

    describe InteractionWithFilters do
      let(:described_class) { InteractionWithFilters }

      %w(thing1 thing2).each do |thing|
        it "adds an attr_reader for #{thing}" do
          expect(interaction).to respond_to thing
        end

        it "adds an attr_writer for #{thing}" do
          expect(interaction).to respond_to "#{thing}="
        end
      end
    end
  end

  describe InteractionWithFilter do
    let(:described_class) { InteractionWithFilter }
    let(:thing) { rand }

    describe '.run(options = {})' do
      subject(:outcome) { described_class.run(options) }

      it "returns an instance of #{described_class}" do
        expect(outcome).to be_a described_class
      end

      context 'failing validations' do
        it 'returns an invalid outcome' do
          expect(outcome).to be_invalid
        end

        it 'sets the result to nil' do
          expect(outcome.result).to be_nil
        end
      end

      context 'passing validations' do
        before { options.merge!(thing: thing) }

        it 'returns a valid outcome' do
          expect(outcome).to be_valid
        end

        it 'sets the result' do
          expect(outcome.result).to eq thing
        end
      end
    end

    describe '.run!(options = {})' do
      subject(:result) { described_class.run!(options) }

      context 'failing validations' do
        it 'raises an error' do
          expect { result }.to raise_error ActiveInteraction::InteractionInvalid
        end
      end

      context 'passing validations' do
        before { options.merge!(thing: thing) }

        it 'returns the result' do
          expect(result).to eq thing
        end
      end
    end
  end

  describe '#execute' do
    it 'raises an error' do
      expect { interaction.execute }.to raise_error NotImplementedError
    end
  end

  describe '#new_record?' do
    it 'returns true' do
      expect(interaction).to be_new_record
    end
  end

  describe '#persisted?' do
    it 'returns false' do
      expect(interaction).to_not be_persisted
    end
  end
end
