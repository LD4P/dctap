# frozen_string_literal: true

module Profiles
  module Sinopia
    # Map Sinopia Profile to DCTAP model
    class Mapper
      def self.build(base_url, profile_id)
        new(base_url, profile_id).build
      end

      def self.recursive_build(base_url, profile_id)
        new(base_url, profile_id).recursive_build
      end

      def initialize(base_url, profile_id)
        @base_url = base_url
        @profile_id = profile_id
      end

      def build
        shape_attrs = {
          id: graph_query.query_first_object_value(profile_uri, SINOPIA.hasResourceId),
          label: graph_query.query_first_object_value(profile_uri, RDF::RDFS.label),
          properties: [map_class, resource_template_property] + map_properties
        }

        Dctap::Models::Shape.new(shape_attrs)
      end

      def recursive_build(shapes: {})
        shapes[profile_id] = build
        shapes[labeled_resource.id] = labeled_resource
        Array(shapes[profile_id].properties).each do |property|
          Array(property.value_shapes).each do |ref_profile_id|
            Mapper.new(base_url, ref_profile_id).recursive_build(shapes: shapes) unless shapes.key?(ref_profile_id)
          end
        end
        shapes.values
      end

      private

      attr_reader :base_url, :profile_id

      def graph_query
        @graph_query ||= Profiles::GraphQuery.new(graph)
      end

      def profile_uri
        @profile_uri ||= RDF::URI.new("#{base_url}/resource/#{profile_id}")
      end

      def graph
        @graph ||= Profiles::GraphLoader.from_uri(profile_uri.value)
      end

      def map_class
        {
          id: RDF::RDFV.type.value,
          label: 'Class',
          mandatory: true,
          repeatable: false,
          value_node_types: ['IRI'],
          value_constraint: graph_query.query_first_object_value(profile_uri, SINOPIA.hasClass)
        }.compact
      end

      def resource_template_property
        {
          id: SINOPIA.hasResourceTemplate.value,
          label: 'Profile ID',
          value_node_types: ['LITERAL'],
          value_constraint: profile_id
        }
      end

      def map_properties
        root_bnode = graph_query.query_first_object(profile_uri, SINOPIA.hasPropertyTemplate)
        property_bnodes = graph_query.query_list_object_values(root_bnode)
        property_bnodes.map do |property_bnode|
          {
            id: graph_query.query_first_object_value(property_bnode, SINOPIA.hasPropertyUri),
            label: graph_query.query_first_object_value(property_bnode, RDF::RDFS.label),
            mandatory: graph_query.match?(property_bnode, SINOPIA.hasPropertyAttribute, SINOPIA_ATTR.required),
            repeatable: graph_query.match?(property_bnode, SINOPIA.hasPropertyAttribute, SINOPIA_ATTR.repeatable),
            ordered: if graph_query.match?(property_bnode, SINOPIA.hasPropertyAttribute,
                                           SINOPIA_ATTR.ordered)
                       'LIST'
                     end,
            note: build_note(property_bnode),
            value_node_types: build_value_node_types(property_bnode),
            value_shapes: build_value_shapes(property_bnode)
          }.compact
        end
      end

      def build_note(property_bnode)
        graph_query.query_first_object_value(property_bnode,
                                             SINOPIA.hasRemark) || graph_query.query_first_object_value(
                                               property_bnode, SINOPIA.hasRemarkUrl
                                             )
      end

      def build_value_node_types(property_bnode)
        case graph_query.query_first_object(property_bnode, SINOPIA.hasPropertyType)
        when SINOPIA_TYPE.resource
          ['BNODE']
        when SINOPIA_TYPE.uri
          %w[LITERAL IRI]
        else
          ['LITERAL']
        end
      end

      def build_value_shapes(property_bnode)
        # Uri's are labeled resources
        return ['sinopia:LabeledResource'] if build_value_node_types(property_bnode).include?('IRI')

        resource_attributes_bnode = graph_query.query_first_object(property_bnode, SINOPIA.hasResourceAttributes)
        return nil if resource_attributes_bnode.nil?

        graph_query.query_all_object_values(resource_attributes_bnode, SINOPIA.hasResourceTemplateId)
      end

      def labeled_resource
        @labeled_resource ||= Dctap::Models::Shape.new({
                                                         id: 'sinopia:LabeledResource',
                                                         label: 'Labeled resource',
                                                         properties: [
                                                           {
                                                             id: RDF::RDFS.label.value,
                                                             label: 'Label',
                                                             value_node_types: ['LITERAL']
                                                           }
                                                         ]
                                                       })
      end
    end
  end
end
