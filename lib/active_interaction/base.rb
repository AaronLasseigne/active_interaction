module ActiveInteraction
  class Base
    extend  ::ActiveModel::Naming
    include ::ActiveModel::Conversion
    include ::ActiveModel::Validations

    def new_record?
      true
    end

    def persisted?
      false
    end

    attr_reader :response

    def initialize(options = {})
      if options.has_key?(:response)
        raise ArgumentError, ':response is reserved and can not be used'
      end

      options.each do |attribute, value|
        instance_variable_set("@#{attribute}".to_sym, value)
      end
    end

    def execute
      raise NotImplementedError
    end

    class << self
      def run(options = {})
        call_execute(new(options))
      end

      def run!(options = {})
        outcome = run(options)

        if !outcome.valid?
          raise InteractionInvalid
        end

        outcome
      end

      private

      def call_execute(obj)
        obj.instance_variable_set(:@response, obj.execute) if obj.valid?

        obj
      end
    end
  end
end
