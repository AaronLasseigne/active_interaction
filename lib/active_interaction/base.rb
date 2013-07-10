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
        if respond_to?("#{attribute}=")
          send("#{attribute}=", value)
        else
          instance_variable_set("@#{attribute}", value)
        end
      end
    end

    def execute
      raise NotImplementedError
    end

    def self.run(options = {})
      me = new(options)

      me.instance_variable_set(:@response, me.execute) if me.valid?

      me
    end

    def self.run!(options = {})
      outcome = run(options)
      raise InteractionInvalid if outcome.invalid?
      outcome
    end

    def self.method_missing(attr_type, *args, &block)
      klass = Attr.factory(attr_type)
      options = args.last.is_a?(Hash) ? args.pop : {}

      args.each do |attribute|
        validator = "_validate__#{attribute}__#{attr_type}"

        attr_accessor attribute

        validate validator

        define_method(validator) do
          begin
            klass.prepare(attribute, send(attribute), options, &block)
          rescue MissingValue
            errors.add(attribute, 'is required')
          rescue InvalidValue
            errors.add(attribute, 'is invalid')
          end
        end
        private validator
      end
    end
    private_class_method :method_missing
  end
end
