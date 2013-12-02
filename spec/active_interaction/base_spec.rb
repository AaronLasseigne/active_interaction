require 'spec_helper'

describe ActiveInteraction::Base do
  include_context 'interactions'

  subject(:interaction) { described_class.new(options) }

  class InteractionWithFilter < described_class
    float :thing

    def execute
      thing
    end
  end

  describe '.new(options = {})' do
    it 'does not allow :_interaction_* as an option' do
      key = :"_interaction_#{SecureRandom.hex}"
      options.merge!(key => nil)
      expect {
        interaction
      }.to raise_error ActiveInteraction::InvalidValueError
    end

    it 'does not allow "_interaction_*" as an option' do
      key = "_interaction_#{SecureRandom.hex}"
      options.merge!(key => nil)
      expect {
        interaction
      }.to raise_error ActiveInteraction::InvalidValueError
    end

    context 'with an attribute' do
      let(:described_class) do
        Class.new(TestInteraction) do
          attr_reader :thing

          validates :thing, presence: true

          def execute
            thing
          end
        end
      end
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

    describe 'with a filter' do
      let(:described_class) { InteractionWithFilter }

      context 'failing validations' do
        before { options.merge!(thing: thing) }

        context 'with an invalid value' do
          let(:thing) { 'a' }

          it 'sets the attribute to the filtered value' do
            expect(interaction.thing).to equal thing
          end
        end

        context 'without a value' do
          let(:thing) { nil }

          it 'sets the attribute to the filtered value' do
            expect(interaction.thing).to equal thing
          end
        end
      end

      context 'passing validations' do
        before { options.merge!(thing: 1) }

        it 'sets the attribute to the filtered value' do
          expect(interaction.thing).to eql 1.0
        end
      end
    end
  end

  describe '.method_missing(filter_type, *args, &block)' do
    it 'raises an error for an invalid filter type' do
      expect {
        Class.new(described_class) do
          not_a_valid_filter_type :thing
        end
      }.to raise_error NoMethodError
    end

    it do
      expect do
        Class.new(described_class) do
          float :_interaction_thing
        end
      end.to raise_error ActiveInteraction::InvalidFilterError
    end

    context 'with a filter' do
      let(:described_class) { InteractionWithFilter }

      it 'adds an attr_reader' do
        expect(interaction).to respond_to :thing
      end

      it 'adds an attr_writer' do
        expect(interaction).to respond_to :thing=
      end
    end

    context 'with multiple filters' do
      let(:described_class) do
        Class.new(ActiveInteraction::Base) do
          float :thing1, :thing2

          def execute; end
        end
      end

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

  context 'with a filter' do
    let(:described_class) { InteractionWithFilter }
    let(:thing) { rand }

    describe '.run(options = {})' do
      it "returns an instance of #{described_class}" do
        expect(outcome).to be_a described_class
      end

      context 'setting the result' do
        let(:described_class) do
          Class.new(TestInteraction) do
            boolean :attribute

            validate do
              @_interaction_result = SecureRandom.hex
              errors.add(:attribute, SecureRandom.hex)
            end
          end
        end

        it 'sets the result to nil' do
          expect(outcome).to be_invalid
          expect(result).to be_nil
        end
      end

      context 'failing validations' do
        it 'returns an invalid outcome' do
          expect(outcome).to_not be_valid
        end

        it 'sets the result to nil' do
          expect(result).to be_nil
        end
      end

      context 'passing validations' do
        before { options.merge!(thing: thing) }

        context 'failing runtime validations' do
          before do
            @execute = described_class.instance_method(:execute)
            described_class.send(:define_method, :execute) do
              errors.add(:thing, 'error')
              errors.add_sym(:thing, :error, 'error')
            end
          end

          after do
            silence_warnings do
              described_class.send(:define_method, :execute, @execute)
            end
          end

          it 'returns an invalid outcome' do
            expect(outcome).to be_invalid
          end

          it 'sets the result to nil' do
            expect(result).to be_nil
          end

          it 'has errors' do
            expect(outcome.errors.messages[:thing]).to eq %w(error error)
          end

          it 'has symbolic errors' do
            expect(outcome.errors.symbolic[:thing]).to eq [:error]
          end
        end

        it 'returns a valid outcome' do
          expect(outcome).to be_valid
        end

        it 'sets the result' do
          expect(result).to eq thing
        end

        it 'calls transaction' do
          allow(described_class).to receive(:transaction)
          outcome
          expect(described_class).to have_received(:transaction).once.
            with(no_args)
        end
      end
    end

    describe '.run!(options = {})' do
      subject(:result) { described_class.run!(options) }

      context 'failing validations' do
        it 'raises an error' do
          expect {
            result
          }.to raise_error ActiveInteraction::InvalidInteractionError
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

  describe '#inputs' do
    let(:described_class) { InteractionWithFilter }
    let(:other_val) { SecureRandom.hex }
    let(:options) { {thing: 1, other: other_val} }

    it 'casts filtered inputs' do
      expect(interaction.inputs[:thing]).to eql 1.0
    end

    it 'strips non-filtered inputs' do
      expect(interaction.inputs).to_not have_key(:other)
    end
  end

  describe '#interact' do
    let(:described_class) { InterruptInteraction }
    let(:x) { rand }
    let(:y) { rand }

    AddInteraction = Class.new(ActiveInteraction::Base) do
      float :x, :y

      def execute
        x + y
      end
    end

    InterruptInteraction = Class.new(ActiveInteraction::Base) do
      model :x, :y,
        class: Object,
        default: nil

      def execute
        interact(AddInteraction, inputs)
      end
    end

    context 'with valid composition' do
      before do
        options.merge!(x: x, y: y)
      end

      it 'is valid' do
        expect(outcome).to be_valid
      end

      it 'returns the sum' do
        expect(result).to eq x + y
      end
    end

    context 'with invalid composition' do
      it 'is invalid' do
        expect(outcome).to be_invalid
      end

      it 'has the correct errors' do
        expect(outcome.errors[:base]).
          to match_array ['X is required', 'Y is required']
      end
    end
  end

  describe '#execute' do
    it 'raises an error' do
      expect { interaction.execute }.to raise_error NotImplementedError
    end
  end
end
