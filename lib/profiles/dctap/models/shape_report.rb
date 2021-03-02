# frozen_string_literal: true

module Profiles
  module Dctap
    module Models
      # Model for a Shape validation report.
      class ShapeReport < Struct
        UNKNOWN_SHAPE = 'Unknown shape'

        attribute :id, Types::String
        attribute :property_reports, Types::Array.of(PropertyReport)
        attribute :errors, Types::Array.of(Types::String.enum(UNKNOWN_SHAPE))

        def valid?
          errors.empty? && property_reports.all?(&:valid?)
        end
      end
    end
  end
end
