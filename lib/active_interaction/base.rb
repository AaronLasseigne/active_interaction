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

    # Returns the output from {#execute} if there are no errors or nil otherwise.
    #
    # @return [Nil] if there are validation errors.
    # @return [Object] if there are no validation errors.
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

    # This must be overridden in a custom ActiveInteraction
    #   class.
    #
    # @raise [NotImplementedError] if the method is not defined.
    def execute
      raise NotImplementedError
    end

    # @!macro [new] run_attributes
    #   @param options [Hash] A hash of attributes values to set.
    #   @return [ActiveInteraction::Base] An instance of the class run is called on.

    # Runs validations and if there are no errors it will call {#execute}.
    #
    # @macro run_attributes
    def self.run(options = {})
      me = new(options)

      me.instance_variable_set(:@response, me.execute) if me.valid?

      me
    end

    # Same as {.run} except that an exception is raised if there are any validation
    #   errors.
    #
    # @macro run_attributes
    # @raise [InteractionInvalid] if there are any errors on the model.
    def self.run!(options = {})
      outcome = run(options)
      raise InteractionInvalid if outcome.invalid?
      outcome
    end

    # @overload hash(:attributes, options = {}, &block)
    #
    # @macro attribute_method_params
    # @param block [Proc] Apply attribute methods to specific values in the hash.
    def self.hash(*args, &block)
      if args.length == 0 && !block_given?
        super
      else
        method_missing(*args, block)
      end
    end

    # @!macro [new] attribute_method_params
    #   @param *attributes [Symbol] A list of attribute names.
    #   @param options [Hash] A hash of options.
    #   @option options [Boolean] :allow_nil Allow a nil value to be passed in.

    # @method self.array(*attributes, options = {}, &block)
    #
    # @macro attribute_method_params
    # @param block [Proc] Apply attribute methods to each entry in the array.

    # @method self.boolean(*attributes, options = {})
    #
    # @macro attribute_method_params

    # @method self.date(*attributes, options = {})
    #
    # @macro attribute_method

    # @method self.date_time(*attributes, options = {})
    #
    # @macro attribute_method_params

    # @method self.float(*attributes, options = {})
    #
    # @macro attribute_method_params

    # @method self.integer(*attributes, options = {})
    #
    # @macro attribute_method_params

    # @method self.model(*attributes, options = {})
    #
    # @macro attribute_method_params

    # @method self.string(*attributes, options = {})
    #
    # @macro attribute_method_params

    # @method self.time(*attributes, options = {})
    #
    # @macro attribute_method_params

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
