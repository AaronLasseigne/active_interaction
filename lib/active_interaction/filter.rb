module ActiveInteraction
  # @private
  class Filter
    TYPES = {}

    def self.inherited(subclass)
      TYPES[extract_class_type(subclass.name)] = subclass
    end

    def self.type
      @type ||= extract_class_type(name).underscore.to_sym
    end

    def self.factory(type)
      TYPES.fetch(type.to_s.camelize) do |type|
        raise NoMethodError, "undefined filter '#{type}' for ActiveInteraction::Base"
      end
    end

    def self.extract_class_type(full_name)
      full_name.match(/\AActiveInteraction::(.*)Filter(?:WithBlock)?\z/).captures.first
    end
    private_class_method :extract_class_type

    attr_reader :name, :options

    def initialize(name, options = {})
      @name, @options = name, options.dup
    end

    def type
      self.class.type
    end

    def block
      Proc.new {}
    end
  end
end
