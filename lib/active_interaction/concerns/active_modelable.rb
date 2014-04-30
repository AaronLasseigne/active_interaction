# coding: utf-8

module ActiveInteraction
  # Implement the minimal ActiveModel interface.
  #
  # @private
  module ActiveModelable
    extend ActiveSupport::Concern
    included do
      extend  ActiveModel::Naming
      include ActiveModel::Validations
      include ActiveModel::Conversion
    end

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

    #
    module ClassMethods
      # @return [Symbol]
      #
      # @see ActiveModel::Translation#i18n_scope
      def i18n_scope
        :active_interaction
      end
    end
  end
end
