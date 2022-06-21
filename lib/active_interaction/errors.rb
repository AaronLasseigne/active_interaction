# frozen_string_literal: true

module ActiveInteraction
  # An extension that provides the ability to merge other errors into itself.
  class Errors < ActiveModel::Errors
    attr_accessor :backtrace

    # Merge other errors into this one.
    #
    # @param other [Errors]
    #
    # @return [Errors]
    def merge!(other)
      merge_details!(other)

      self
    end

    # @private
    def local_attribute(attribute)
      attribute.to_s.sub(/\A([^.\[]*).*\z/, '\1').to_sym
    end

    private

    def attribute?(attribute)
      @base.respond_to?(local_attribute(attribute))
    end

    def detailed_error?(detail)
      detail[:error].is_a?(Symbol)
    end

    def merge_message!(attribute, message)
      unless attribute?(attribute)
        message = full_message(attribute, message)
        attribute = :base
      end
      add(attribute, message) unless added?(attribute, message)
    end

    def merge_details!(other)
      other.messages.each do |attribute, messages|
        messages.zip(other.details[attribute]) do |message, detail|
          if detailed_error?(detail)
            merge_detail!(attribute, detail, message)
          else
            merge_message!(attribute, message)
          end
        end
      end
    end

    def merge_detail!(attribute, detail, message)
      if attribute?(attribute) || attribute == :base
        options = detail.dup
        error = options.delete(:error)

        add(attribute, error, **options.merge(message: message)) unless added?(attribute, error, **options)
      else
        merge_message!(attribute, message)
      end
    end
  end
end
