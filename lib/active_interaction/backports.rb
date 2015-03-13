# coding: utf-8

# rubocop:disable Documentation
module ActiveInteraction
  class Errors
    # Required for Rails < 3.2.13.
    protected :initialize_dup
  end
end

# @private
class Hash
  # Required for Rails < 4.0.0.
  def transform_keys
    result = {}
    each_key do |key|
      result[yield(key)] = self[key]
    end
    result
  end unless method_defined?(:transform_keys)
end
