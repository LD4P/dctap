# frozen_string_literal: true

module Profiles
  module Dctap
    # Write model to DCTAP CSV files.
    class Writer
      def self.write(filepath, shapes)
        new(filepath, shapes).write
      end

      def initialize(filepath, shapes)
        @filepath = filepath
        @shapes = Array(shapes)
      end

      def write
        CSV.open(filepath, 'w') do |csv|
          csv << %w[shapeID shapeLabel propertyID propertyLabel mandatory repeatable ordered
                    valueNodeType valueConstraint valueShape note]
          shapes.each do |shape|
            shape.properties.each do |property|
              csv << [shape.id,
                      shape.label,
                      property.id,
                      property.label,
                      property.mandatory.to_s.downcase,
                      property.repeatable,
                      property.ordered,
                      property.value_node_types&.join('|'),
                      property.value_constraint,
                      property.value_shapes&.join('|'),
                      property.note]
            end
          end
        end
      end

      private

      attr_reader :filepath, :shapes
    end
  end
end
