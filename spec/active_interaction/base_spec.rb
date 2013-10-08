require 'spec_helper'

describe ActiveInteraction::Base do
  let(:options) { {} }
  subject(:interaction) { described_class.new(options) }

  class InteractionWithFilter < described_class
    float :thing

    def execute
      thing
    end
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

    context 'with an attribute' do
      let(:described_class) do
        Class.new(ActiveInteraction::Base) do
          attr_reader :thing

          validates :thing, presence: true

          def self.name
            SecureRandom.hex
          end

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

        it 'calls transaction' do
          allow(described_class).to receive(:transaction)
          outcome
          expect(described_class).to have_received(:transaction).once.
            with(no_args)
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

          it 'calls ActiveRecord::Base.transaction' do
            outcome
            expect(ActiveRecord::Base).to have_received(:transaction).once.
              with(no_args)
          end
        end
      end
    end

    describe '.run!(options = {})' do
      subject(:result) { described_class.run!(options) }

      context 'failing validations' do
        it 'raises an error' do
          expect {
            result
          }.to raise_error ActiveInteraction::InteractionInvalid
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

  describe '.i18n_scope' do
    it 'returns the scope' do
      expect(described_class.i18n_scope).to eq :active_interaction
    end
  end

  describe '#i18n_scope' do
    it 'returns the scope' do
      expect(interaction.i18n_scope).to eq :active_interaction
    end
  end

  describe '.description' do
    let(:description) { SecureRandom.hex }

    it do
      expect(described_class.description).to be_nil
    end

    it do
      described_class.description(description)
      expect(described_class.description).to eq description
    end
  end
end
