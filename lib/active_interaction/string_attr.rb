module ActiveInteraction
  module StringAttr
    extend Attr

    DEFAULT_OPTIONS = {
      allow_nil: false
    }.freeze

    def self.prepare(value, options = {})
      options = DEFAULT_OPTIONS.merge(options)

      case value
        when String
          value
        when NilClass
          return_nil(options[:allow_nil])
        else
          bad_value
      end
    end
  end
end
