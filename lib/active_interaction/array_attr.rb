module ActiveInteraction
  module ArrayAttr
    extend Attr

    def self.prepare(_, value, options = {}, &block)
      case value
        when Array
          convert_values(value, &block)
        when NilClass
          return_nil(options[:allow_nil])
        else
          bad_value
      end
    end

    def self.convert_values(values, &block)
      return values unless block_given?

      block_attrs = ActiveInteraction::AttrBlock.evaluate(&block)
      raise ArgumentError if block_attrs.count > 1

      attr_type, options, internal_block = block_attrs.first

      values.map do |value|
        ActiveInteraction::Attr.factory(attr_type).prepare(nil, value, options, &internal_block)
      end
    end
    private_class_method :convert_values
  end
end
