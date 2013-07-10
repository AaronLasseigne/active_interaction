require 'active_support/core_ext/hash/indifferent_access'

module ActiveInteraction
  # @abstract Subclass and override {#execute} to implement
  #   a custom ActiveInteraction class.
  class Base
    extend  ::ActiveModel::Naming
    include ::ActiveModel::Conversion
    include ::ActiveModel::Validations

    # @private
    def new_record?
      true
    end

    # @private
    def persisted?
      false
    end

    attr_reader :response

    # @private
    def initialize(options = {})
      options = options.with_indifferent_access

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

    # @overload hash(:attributes, options = {}, &block)
    def self.hash(*args, &block)
      if args.length == 0 && !block_given?
        super
      else
        method_missing(*args, block)
      end
    end

    # @method self.array(:attributes, options = {}, &block)

    # @method self.boolean(:attributes, options = {})

    # @method self.date(:attributes, options = {})

    # @method self.date_time(:attributes, options = {})

    # @method self.float(:attributes, options = {})

    # @method self.integer(:attributes, options = {})

    # @method self.model(:attributes, options = {})

    # @method self.string(:attributes, options = {})

    # @method self.time(:attributes, options = {})

    # @private
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
