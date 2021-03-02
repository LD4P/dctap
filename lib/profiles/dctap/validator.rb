# frozen_string_literal: true

module Profiles
  module Dctap
    # Validator for RDF against DCTAP profiles.
    class Validator
      include Dry::Monads[:result]

      def self.validate(subject_term, shape_id, graph, shapes, strict: true)
        new(subject_term, shape_id, graph, shapes, strict: strict).validate
      end

      def initialize(subject_term, shape_id, graph, shapes, strict: true)
        @graph = graph
        @shapes = Array(shapes)
        @subject_term = subject_term
        @shape_id = shape_id
        @strict = strict
      end

      def validate
        shape_result = shape_for_shape_id(shape_id)
        shape_report = if shape_result.success?
                         build_shape_report(shape_result.value!)
                       else
                         unknown_shape_report(subject_term)
                       end
        Models::ShapeReport.new(shape_report)
      end

      private

      attr_reader :shapes, :graph, :shape_id, :subject_term, :strict

      def shape_for_shape_id(shape_id)
        match = shapes.find { |shape| shape.id == shape_id }
        match ? Success(match) : Failure()
      end

      def shape_for_class(clazz)
        match = shapes.find do |shape|
          shape.properties.any? { |property| property.id == RDF::RDFV.type.value && property.value_constraint == clazz }
        end
        match ? Success(match) : Failure()
      end

      def graph_query
        @graph_query ||= Profiles::GraphQuery.new(graph)
      end

      def build_shape_report(shape)
        {
          id: shape_id,
          property_reports: shape.properties.map do |property|
                              build_property_report(property)
                            end + build_unexpected_property_reports(shape),
          errors: []
        }
      end

      def build_property_report(property)
        objects = graph_query.query_all_objects(subject_term, RDF::URI.new(property.id))
        list_objects = graph_query.query_list_object_values(objects.first)
        property_objects = property.ordered == 'LIST' ? list_objects : objects
        {
          id: property.id,
          errors: validate_property(property, objects, property_objects),
          value_reports: property_objects.map { |object| build_value_report(property, object) }
        }
      end

      def build_unexpected_property_reports(shape)
        return [] unless strict

        predicate_objects = graph_query.query_all_predicates_objects(subject_term)
        expected_properties = shape.properties.map(&:id)
        predicate_objects.map do |predicate, _object|
          next nil if expected_properties.include?(predicate.value)

          {
            id: predicate.value,
            errors: [Models::PropertyReport::UNEXPECTED_PROPERTY],
            value_reports: []
          }
        end.compact
      end

      def validate_property(property, objects, property_objects)
        errors = []
        errors << Models::PropertyReport::MANDATORY_PROPERTY_MISSING if property.mandatory && property_objects.empty?
        errors << Models::PropertyReport::REPEATED_ERROR if !property.repeatable && property_objects.size > 1
        # If a list, then must have a single object that is a bnode that has a RDF::RDFV.rest property.
        errors << Models::PropertyReport::NOT_LIST if property.ordered == 'LIST' && !list?(objects)
        errors
      end

      def list?(objects)
        # If a list, then must have a single object that is a bnode that has a RDF::RDFV.rest property.
        return false if objects.size > 1

        objects.empty? || graph_query.match?(objects.first, RDF::RDFV.rest)
      end

      def build_value_report(property, object)
        {
          value: object.to_s,
          errors: validate_value(property, object),
          shape_report: recursive_validate(property, object)
        }.compact
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def validate_value(property, object)
        if object.iri? && !property.value_node_types.include?('IRI') ||
           object.literal? && !property.value_node_types.include?('LITERAL') ||
           object.node? && !property.value_node_types.include?('BNODE')
          return [Models::ValueReport::INCORRECT_NODE_TYPE]
        end

        errors = []
        if (property.value_node_types.include?('IRI') || property.value_node_types.include?('LITERAL')) &&
           property.value_constraint && object.value != property.value_constraint
          errors << Models::ValueReport::VALUE_CONSTRAINT_MISMATCH
        end

        errors
      end
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity

      def recursive_validate(property, object)
        return nil unless (object.iri? || object.node?) && property.value_shapes.present?

        if property.value_shapes.size == 1
          return Validator.validate(object, property.value_shapes.first, graph, shapes,
                                    strict: strict)
        end

        # Select based on class.
        clazz = graph_query.query_first_object_value(object, RDF::RDFV.type)
        return missing_class_report(object) if clazz.nil?

        shape_result = shape_for_class(clazz)
        return unknown_shape_report(object) if shape_result.failure?

        Validator.validate(object, shape_result.value!.id, graph, shapes, strict: strict)
      end

      def missing_class_report(subject)
        {
          id: subject.to_s,
          property_reports: [
            {
              id: RDF::RDFV.type.value,
              errors: [Models::PropertyReport::MANDATORY_PROPERTY_MISSING],
              value_reports: []
            }
          ],
          errors: []
        }
      end

      def unknown_shape_report(subject)
        {
          id: subject.to_s,
          property_reports: [],
          errors: [Models::ShapeReport::UNKNOWN_SHAPE]
        }
      end
    end
  end
end
