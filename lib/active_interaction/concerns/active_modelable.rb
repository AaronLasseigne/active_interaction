# frozen_string_literal: true

module ActiveInteraction
  # Implement the minimal ActiveModel interface.
  #
  # @private
  module ActiveModelable
    extend ActiveSupport::Concern

    include ActiveModel::Conversion
    include ActiveModel::Validations

    extend ActiveModel::Naming

    # @return (see ClassMethods#i18n_scope)
    #
    # @see ActiveModel::Translation#i18n_scope
    def i18n_scope
      self.class.i18n_scope
    end

    # @return [Boolean]
    #
    # @see ActiveRecord::Presistence#new_record?
    def new_record?
      true
    end

    # @return [Boolean]
    #
    # @see ActiveRecord::Presistence#persisted?
    def persisted?
      false
    end

    module ClassMethods # rubocop:disable Style/Documentation
      # @return [Symbol]
      #
      # @see ActiveModel::Translation#i18n_scope
      def i18n_scope
        :active_interaction
      end
    end
  end
end
