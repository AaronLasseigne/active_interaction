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

    # Returns the output from {#execute} if there are no errors or `nil` otherwise.
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

    # Runs the business logic associated with the interactor. The method is only
    #   run when there are no validation errors. The return value is placed into
    #   {#response}. This method must be overridden in the subclass.
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

    # @!macro [new] attribute_method_params
    #   @param *attributes [Symbol] A list of attribute names.
    #   @param options [Hash] A hash of options.
    #   @option options [Boolean] :allow_nil Allow a nil value to be passed in.

    # Confirms that any values passed to the provided attributes are Arrays.
    #
    # @macro attribute_method_params
    # @param block [Proc] Apply attribute methods to each entry in the array.
    #
    # @example
    #   array :ids
    #
    # @example An Array of Integers
    #   array :ids do
    #     integer
    #   end
    #
    # @example An Array of Integers where some are nil
    #   array :ids do
    #     integer allow_nil: true
    #   end
    #
    # @method self.array(*attributes, options = {}, &block)

    # Confirms that any values passed to the provided attributes are Booleans.
    #   The String "1" is converted to `true` and "0" is converted to `false`.
    #
    # @macro attribute_method_params
    #
    # @example
    #   boolean :subscribed
    #
    # @method self.boolean(*attributes, options = {})

    # Confirms that any values passed to the provided attributes are Dates.
    #
    # @macro attribute_method_params
    #
    # @example
    #   date :birthday
    #
    # @method self.date(*attributes, options = {})

    # Confirms that any values passed to the provided attributes are DateTimes.
    #
    # @macro attribute_method_params
    #
    # @example
    #   date_time :start_date
    #
    # @method self.date_time(*attributes, options = {})

    # Confirms that any values passed to the provided attributes are Files.
    #
    # @macro attribute_method_params
    #
    # @example
    #   file :image
    #
    # @method self.file(*attributes, options = {})

    # Confirms that any values passed to the provided attributes are Floats.
    #
    # @macro attribute_method_params
    #
    # @example
    #   float :amount
    #
    # @method self.float(*attributes, options = {})

    # Confirms that any values passed to the provided attributes are Hashes.
    #
    # @macro attribute_method_params
    # @param block [Proc] Apply attribute methods to specific values in the hash.
    #
    # @example
    #   hash :order
    #
    # @example A Hash where certain keys also have their values confirmed.
    #   hash :order do
    #     model :account
    #     model :item
    #     integer :quantity
    #     boolean :delivered
    #   end
    #
    # @method self.hash(*attributes, options = {}, &block)
    def self.hash(*args, &block)
      if args.length == 0 && !block_given?
        super
      elsif block_given?
        method_missing(:hash, *args, &block)
      else
        method_missing(:hash, *args)
      end
    end

    # Confirms that any values passed to the provided attributes are Integers.
    #
    # @macro attribute_method_params
    #
    # @example
    #   integer :quantity
    #
    # @method self.integer(*attributes, options = {})

    # Confirms that any values passed to the provided attributes are the correct Class.
    #
    # @macro attribute_method_params
    # @option options [Class, String, Symbol] :class (use the attribute name) Class name used to confirm the provided value.
    #
    # @example Confirms that the Class is `Account`
    #   model :account
    #
    # @example Confirms that the Class is `User`
    #   model :account, class: User
    #
    # @method self.model(*attributes, options = {})

    # Confirms that any values passed to the provided attributes are Strings.
    #
    # @macro attribute_method_params
    #
    # @example
    #   string :first_name
    #
    # @method self.string(*attributes, options = {})

    # Confirms that any values passed to the provided attributes are Times.
    #
    # @macro attribute_method_params
    #
    # @example
    #   time :start_date
    #
    # @method self.time(*attributes, options = {})

    # @private
    def self.method_missing(filter_type, *args, &block)
      klass = Filter.factory(filter_type)
      options = args.last.is_a?(Hash) ? args.pop : {}

      args.each do |attribute|
        validator = "_validate__#{attribute}__#{filter_type}"

        attr_accessor attribute

        validate validator

        define_method(validator) do
          begin
            klass.prepare(attribute, send(attribute), options, &block)
          rescue MissingValue
            errors.add(attribute, 'is required')
          rescue InvalidValue
            errors.add(attribute,
                "is not a valid #{filter_type.to_s.humanize.downcase}")
          end
        end
        private validator
      end
    end
    private_class_method :method_missing
  end
end
