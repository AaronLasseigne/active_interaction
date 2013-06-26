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

    def execute
      raise NotImplementedError
    end

    class << self
      def run(options = {})
        if options.has_key?(:response)
          raise ArgumentError, ':response is reserved and can not be used'
        end

        call_execute(create(options))
      end

      private

      def create(options)
        obj = new

        options.each do |attribute, value|
          obj.instance_variable_set("@#{attribute}".to_sym, value)
        end

        obj
      end

      def call_execute(obj)
        obj.instance_variable_set(:@response, obj.execute) if obj.valid?

        obj
      end
    end
  end
end
