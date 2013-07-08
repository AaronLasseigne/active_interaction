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
      if block_attrs.count > 1
        raise ArgumentError
      else
        block_attr = block_attrs.first
      end

      values.map do |value|
        ActiveInteraction::Attr.factory(block_attr.method_name).prepare(block_attr.attribute, value, block_attr.options, &block_attr.block)
      end
    end
    private_class_method :convert_values
  end
end
