shared_examples 'options includes :allow_nil' do
  context 'options' do
    context ':allow_nil' do
      context 'is true' do
        it 'allows the options to be set to nil' do
          expect(described_class.prepare(:key, nil, allow_nil: true)).to eq nil
        end
      end

      context 'is false' do
        it 'throws an error' do
          expect {
            described_class.prepare(:key, nil, allow_nil: false)
          }.to raise_error ArgumentError
        end
      end
    end
  end
end
