shared_context 'concerns' do |concern|
  subject(:instance) { klass.new }

  let(:klass) do
    Class.new do
      include concern

      def self.name
        SecureRandom.hex
      end
    end
  end
end
