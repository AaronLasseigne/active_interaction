# frozen_string_literal: true

require 'erb'

#
module ActiveInteraction
  # Top-level error class. All other errors subclass this.
  #
  # @return [Class]
  Error = Class.new(StandardError)

  # Raised if a constant name is invalid.
  #
  # @return [Class]
  InvalidNameError = Class.new(Error)

  # Raised if a converter is invalid.
  #
  # @return [Class]
  InvalidConverterError = Class.new(Error)

  # Raised if a default value is invalid.
  #
  # @return [Class]
  InvalidDefaultError = Class.new(Error)

  # Raised if a filter has an invalid definition.
  #
  # @return [Class]
  InvalidFilterError = Class.new(Error)

  # Raised if an interaction is invalid.
  #
  # @return [Class]
  InvalidInteractionError = Class.new(Error)

  # Raised if a user-supplied value is invalid.
  #
  # @return [Class]
  InvalidValueError = Class.new(Error)

  # Raised if a filter cannot be found.
  #
  # @return [Class]
  MissingFilterError = Class.new(Error)

  # Raised if no value is given.
  #
  # @return [Class]
  MissingValueError = Class.new(Error)

  # Raised if there is no default value.
  #
  # @return [Class]
  NoDefaultError = Class.new(Error)

  # Raised if a user-supplied value to a nested hash input is invalid.
  #
  # @return [Class]
  class InvalidNestedValueError < InvalidValueError
    # @return [Symbol]
    attr_reader :filter_name

    # @return [Object]
    attr_reader :input_value

    # @param filter_name [Symbol]
    # @param input_value [Object]
    def initialize(filter_name, input_value)
      super("#{filter_name}: #{input_value.inspect}")

      @filter_name = filter_name
      @input_value = input_value
    end
  end

  # Used by {Runnable} to signal a failure when composing.
  #
  # @private
  class Interrupt < Error
    attr_reader :errors, :moves

    # @param errors [Runnable]
    def initialize(errors, moves)
      super()

      @errors = errors
      @moves = moves
    end
  end
  private_constant :Interrupt

  # An extension that provides the ability to merge other errors into itself.
  class Errors < ActiveModel::Errors
    # Merge other errors into this one. All errors are merged to base unless
    #   they were specified using the `:move` attribute.
    #
    # @param other [Errors]
    # @param move [Hash] A mapping of errors where the key is an attribute on
    #   `other` that you would liked mapped to an attribute on the current
    #   interaction.
    #
    # @return [Errors]
    def merge!(other, move: {})
      if other.respond_to?(:details)
        merge_details!(other, move)
      else
        merge_messages!(other, move)
      end

      self
    end

    private

    def merge_messages!(other, move)
      other.messages.each do |from, messages|
        to = move.fetch(from, :base)

        messages.each do |message|
          message = full_message(from, message) if to == :base

          add(to, message) unless added?(to, message)
        end
      end
    end

    def merge_details!(other, move)
      other.details.each do |from, details|
        to = move.fetch(from, :base)

        details.each do |detail|
          detail = detail.dup
          error = detail.delete(:error)

          if to == :base
            translated_error = translate(other, from, error, detail)
            message = full_message(from, translated_error)

            add(to, message) unless added?(to, message)
          else
            add(to, error, detail) unless added?(to, error, detail)
          end
        end
      end
    end

    def attribute?(attribute)
      @base.respond_to?(attribute)
    end

    def translate(other, attribute, error, detail)
      if error.is_a?(Symbol)
        other.generate_message(attribute, error, detail)
      else
        error
      end
    end
  end

  # Generate more detailed and human friendly error messages.
  class ErrorMessage
    def initialize(options)
      @title = options[:title]
      @issue = options[:issue]
      @fix   = options[:fix]
    end

    attr_reader :title, :issue, :fix

    def mark_bad_lines(code, bad_lines)
      lines = code.split("\n")

      if bad_lines.is_a?(Range)
        replacement = 0.upto(lines.size - 1).to_a
        bad_lines = replacement[bad_lines.begin]..replacement[bad_lines.end]
      end

      lines.map.with_index do |line, i|
        "#{bad_lines.include?(i) ? '✗' : ' '} #{line}"
      end.join("\n")
    end

    def to_str
      correct_spacing(ERB.new(strip_heredoc(<<-MESSAGE), nil, '-').result(binding))
        ## Issue

        <%= issue[:desc] %>

        <% if issue[:code] -%>
        <%= mark_bad_lines(issue[:code], issue[:lines]) %>
        <% end -%>

        (The code above is generated and may not be identical to yours.)

        <% if fix && (!fix[:if] || fix[:if].call) -%>
        ## Fix

        <%= fix[:desc] %>

        <% if fix[:code] -%>
        <%= mark_bad_lines(fix[:code], []) %>
        <% end -%>
        <% end -%>
      MESSAGE
    end

    private def strip_heredoc(text)
      text.gsub(/^#{text.scan(/^[ \t]*(?=\S)/).min}/, '')
    end

    private def correct_spacing(text)
      text.strip.prepend("\n\n").concat("\n\n")
    end
  end
end
