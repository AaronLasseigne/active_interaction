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

    def self.run(options = {})
      me = new(options)

      me.instance_variable_set(:@response, me.execute) if me.valid?

      me
    end

    def self.run!(options = {})
      outcome = run(options)

      if !outcome.valid?
        raise InteractionInvalid
      end

      outcome
    end

    def self.method_missing(attr_type, *args, &block)
      klass = "#{attr_type.to_s.capitalize}Attr"

      super unless ActiveInteraction.const_defined?(klass)

      options = {}
      if args.last.is_a?(Hash)
        options = args.pop
      end
      method_names = args

      method_names.each do |method_name|
        class_eval %Q(
          def #{method_name}
            @#{method_name}
          end
          def #{method_name}=(value)
            @#{method_name} = #{klass}.prepare(method_name, value, #{options})
          end
        )
      end
    end
    private_class_method :method_missing
  end
end
