RSpec.describe ActiveInteraction::HashFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  context 'with a nested nameless filter' do
    let(:block) { proc { hash } }

    it 'raises an error' do
      expect { filter }.to raise_error ActiveInteraction::InvalidFilterError
    end
  end

  describe '#process' do
    let(:result) { filter.process(value, nil) }

    context 'with a Hash' do
      let(:value) { {} }

      it 'returns the Hash' do
        expect(result.value).to eql value
        expect(result.value).to be_an_instance_of HashWithIndifferentAccess
      end
    end

    context 'with an implicit Hash' do
      let(:value) do
        Class.new do
          def to_hash
            {}
          end
        end.new
      end

      it 'returns the Hash' do
        expect(result.value).to eql value.to_hash
      end
    end

    context 'with a non-empty Hash' do
      let(:value) { { a: {} } }

      it 'returns an empty Hash' do
        expect(result.value).to eql({})
      end
    end

    context 'with a nested filter' do
      let(:block) { proc { hash :a } }

      context 'with a Hash' do
        let(:value) { { 'a' => {} } }

        it 'returns the Hash' do
          expect(result.value).to eql value
          expect(result.value).to be_an_instance_of HashWithIndifferentAccess
        end

        context 'with String keys' do
          before do
            value.stringify_keys!
          end

          it 'does not raise an error' do
            expect { result }.to_not raise_error
          end
        end
      end

      context 'without a Hash' do
        let(:k) { 'a' }
        let(:v) { double }
        let(:value) { { k => v } }

        it 'indicates an error' do
          error = result.errors.first

          expect(result.errors.size).to be 1
          expect(error).to be_an_instance_of ActiveInteraction::Filter::Error
          expect(error.name).to be :"#{filter.name}.#{error.filter.name}"
          expect(error.type).to be :invalid_type
        end
      end
    end

    context 'with :strip false' do
      let(:options) { { strip: false } }

      context 'with a non-empty Hash' do
        let(:value) { { 'a' => {} } }

        it 'returns an empty Hash' do
          expect(result.value).to eql value
        end
      end
    end
  end

  describe '#default' do
    context 'with a Hash' do
      before do
        options[:default] = {}
      end

      it 'returns the Hash' do
        expect(filter.default(nil)).to eql options[:default]
      end
    end

    context 'with a non-empty Hash' do
      before do
        options[:default] = { a: {} }
      end

      it 'raises an error' do
        expect do
          filter.default(nil)
        end.to raise_error ActiveInteraction::InvalidDefaultError
      end
    end
  end

  describe '#database_column_type' do
    it 'returns :string' do
      expect(filter.database_column_type).to be :string
    end
  end

  describe 'nesting limit' do
    def nested_hash(depth)
      (1..depth).inject({ leaf: 1 }) { |acc, _| { k: acc } }
    end

    it 'does not crash with SystemStackError on a very deeply nested hash' do
      # Without the nesting cap this raises SystemStackError around ~5k deep,
      # because HashWithIndifferentAccess recursively re-wraps nested hashes.
      expect { filter.process(nested_hash(10_000), nil) }.not_to raise_error
    end

    it 'rejects hashes beyond the limit with a filter error' do
      result = filter.process(nested_hash(10_000), nil)
      expect(result.errors.first).to be_an_instance_of(ActiveInteraction::Filter::Error)
      expect(result.errors.first.type).to be :invalid_type
    end

    it 'counts depth through arrays, since HashWithIndifferentAccess recurses into them' do
      mixed = { a: [{ b: [{ c: nested_hash(10_000) }] }] }
      expect { filter.process(mixed, nil) }.not_to raise_error
    end
  end
end
