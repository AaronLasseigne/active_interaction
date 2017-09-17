shared_context 'concerns' do |concern|
  let(:klass) do
    Class.new do
      include concern

      def self.name
        SecureRandom.hex
      end
    end
  end

  subject(:instance) { klass.new }
end
