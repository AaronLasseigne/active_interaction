module ActiveInteraction
  module IntegerAttr
    extend Attr

    DEFAULT_OPTIONS = {
      allow_nil: false
    }.freeze

    def self.prepare(value, options = {})
      options = DEFAULT_OPTIONS.merge(options)

      case value
        when Integer
          value
        when String
          begin
            Integer(value)
          rescue ArgumentError
            bad_value
          end
        when NilClass
          return_nil(options[:allow_nil])
        else
          bad_value
      end
    end
  end
end
