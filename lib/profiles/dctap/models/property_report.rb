# frozen_string_literal: true

module Profiles
  module Dctap
    module Models
      # Model for a Property validation report.
      class PropertyReport < Struct
        MANDATORY_PROPERTY_MISSING = 'Mandatory property is missing.'
        REPEATED_ERROR = 'Non-repeatable property is repeated.'
        NOT_LIST = 'Not a list.'
        UNEXPECTED_PROPERTY = 'Unexpected property.'

        attribute :id, Types::String
        attribute :value_reports, Types::Array.of(ValueReport)
        attribute :errors, Types::Array.of(Types::String.enum(MANDATORY_PROPERTY_MISSING,
                                                              REPEATED_ERROR,
                                                              NOT_LIST,
                                                              UNEXPECTED_PROPERTY))

        def valid?
          errors.empty? && value_reports.all?(&:valid?)
        end
      end
    end
  end
end
