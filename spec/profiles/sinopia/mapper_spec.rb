# frozen_string_literal: true

RSpec.describe Profiles::Sinopia::Mapper do
  let(:shape) { described_class.build('https://api.development.sinopia.io', 'sinopia:test:Monograph:Instance') }

  let(:ttl) do
    <<~TTL
      <https://api.development.sinopia.io/resource/sinopia:test:Monograph:Instance> <http://sinopia.io/vocabulary/hasResourceTemplate> "sinopia:template:resource";
          a <http://sinopia.io/vocabulary/ResourceTemplate>;
          <http://sinopia.io/vocabulary/hasResourceId> "sinopia:test:Monograph:Instance"@eng;
          <http://sinopia.io/vocabulary/hasClass> <http://id.loc.gov/ontologies/bibframe/Instance>;
          <http://www.w3.org/2000/01/rdf-schema#label> "Sinopia Test Instance (Monograph)"@eng;
          <http://sinopia.io/vocabulary/hasAuthor> "Justin Littman"@eng;
          <http://sinopia.io/vocabulary/hasRemark> "This is a template for testing DCMI Application Profiles."@eng;
          <http://sinopia.io/vocabulary/hasDate> "03-02-2021"@eng;
          <http://sinopia.io/vocabulary/hasPropertyTemplate> _:b37.
      _:b37 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:b38;
          <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> _:b39.
      _:b39 a <http://sinopia.io/vocabulary/PropertyTemplate>;
          <http://sinopia.io/vocabulary/hasPropertyUri> <http://id.loc.gov/ontologies/bibframe/title>;
          <http://www.w3.org/2000/01/rdf-schema#label> "Title information"@eng;
          <http://sinopia.io/vocabulary/hasPropertyAttribute> <http://sinopia.io/vocabulary/propertyAttribute/required>.
      <http://sinopia.io/vocabulary/propertyAttribute/required> <http://www.w3.org/2000/01/rdf-schema#label> "required".
      _:b39 <http://sinopia.io/vocabulary/hasPropertyType> <http://sinopia.io/vocabulary/propertyType/literal>.
      <http://sinopia.io/vocabulary/propertyType/literal> <http://www.w3.org/2000/01/rdf-schema#label> "literal".
      _:b38 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:b40;
          <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> _:b41.
      _:b41 a <http://sinopia.io/vocabulary/PropertyTemplate>;
          <http://sinopia.io/vocabulary/hasPropertyUri> <http://id.loc.gov/ontologies/bibframe/copyrightDate>;
          <http://www.w3.org/2000/01/rdf-schema#label> "Copyright Date"@eng;
          <http://sinopia.io/vocabulary/hasRemark> "Include copyright symbol or use the term copyright."@eng;
          <http://sinopia.io/vocabulary/hasPropertyAttribute> <http://sinopia.io/vocabulary/propertyAttribute/repeatable>.
      <http://sinopia.io/vocabulary/propertyAttribute/repeatable> <http://www.w3.org/2000/01/rdf-schema#label> "repeatable".
      _:b41 <http://sinopia.io/vocabulary/hasPropertyType> <http://sinopia.io/vocabulary/propertyType/literal>.
      _:b40 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:b42;
          <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> _:b43.
      _:b43 a <http://sinopia.io/vocabulary/PropertyTemplate>;
          <http://sinopia.io/vocabulary/hasPropertyUri> <http://id.loc.gov/ontologies/bibframe/identifiedBy>;
          <http://www.w3.org/2000/01/rdf-schema#label> "Identifiers"@eng;
          <http://sinopia.io/vocabulary/hasPropertyAttribute> <http://sinopia.io/vocabulary/propertyAttribute/repeatable>;
          <http://sinopia.io/vocabulary/hasPropertyType> <http://sinopia.io/vocabulary/propertyType/resource>.
      <http://sinopia.io/vocabulary/propertyType/resource> <http://www.w3.org/2000/01/rdf-schema#label> "nested resource".
      _:b43 <http://sinopia.io/vocabulary/hasResourceAttributes> _:b44.
      _:b44 a <http://sinopia.io/vocabulary/ResourcePropertyTemplate>;
          <http://sinopia.io/vocabulary/hasResourceTemplateId> <ld4p:RT:bf2:Identifiers:LCCN>.
      <ld4p:RT:bf2:Identifiers:LCCN> <http://www.w3.org/2000/01/rdf-schema#label> "LCCN (ld4p:RT:bf2:Identifiers:LCCN)".
      _:b44 <http://sinopia.io/vocabulary/hasResourceTemplateId> <ld4p:RT:bf2:Identifiers:ISBN>.
      <ld4p:RT:bf2:Identifiers:ISBN> <http://www.w3.org/2000/01/rdf-schema#label> "ISBN (ld4p:RT:bf2:Identifiers:ISBN)".
      _:b42 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:b45;
          <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> _:b46.
      _:b46 a <http://sinopia.io/vocabulary/PropertyTemplate>;
          <http://sinopia.io/vocabulary/hasPropertyUri> <http://id.loc.gov/ontologies/bibframe/instanceOf>;
          <http://www.w3.org/2000/01/rdf-schema#label> "Instance of"@eng;
          <http://sinopia.io/vocabulary/hasPropertyType> <http://sinopia.io/vocabulary/propertyType/uri>.
      <http://sinopia.io/vocabulary/propertyType/uri> <http://www.w3.org/2000/01/rdf-schema#label> "uri or lookup".
      _:b46 <http://sinopia.io/vocabulary/hasLookupAttributes> _:b47.
      _:b47 a <http://sinopia.io/vocabulary/LookupPropertyTemplate>;
          <http://sinopia.io/vocabulary/hasAuthority> <urn:ld4p:sinopia:bibframe:work>.
      <urn:ld4p:sinopia:bibframe:work> <http://www.w3.org/2000/01/rdf-schema#label> "Sinopia BIBFRAME work resources".
      _:b45 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil>;
          <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> _:b48.
      _:b48 a <http://sinopia.io/vocabulary/PropertyTemplate>;
          <http://sinopia.io/vocabulary/hasPropertyUri> <http://id.loc.gov/ontologies/bibframe/note>;
          <http://www.w3.org/2000/01/rdf-schema#label> "Note about the instance"@eng;
          <http://sinopia.io/vocabulary/hasRemarkUrl> <http://access.rdatoolkit.org/2.17.html>;
          <http://sinopia.io/vocabulary/hasPropertyAttribute> <http://sinopia.io/vocabulary/propertyAttribute/repeatable>, <http://sinopia.io/vocabulary/propertyAttribute/ordered>.
      <http://sinopia.io/vocabulary/propertyAttribute/ordered> <http://www.w3.org/2000/01/rdf-schema#label> "ordered".
      _:b48 <http://sinopia.io/vocabulary/hasPropertyType> <http://sinopia.io/vocabulary/propertyType/literal>.
    TTL
  end

  let(:graph) { Profiles::GraphLoader.from_ttl(ttl) }

  before do
    allow(Profiles::GraphLoader).to receive(:from_uri).and_return(graph)
  end

  it 'maps shape' do
    expect(shape.id).to eq('sinopia:test:Monograph:Instance')
    expect(shape.label).to eq('Sinopia Test Instance (Monograph)')
  end

  it 'maps properties' do
    puts JSON.pretty_generate(shape.to_h)
    expect(shape.properties.size).to eq(7)

    property = property_for('http://id.loc.gov/ontologies/bibframe/copyrightDate')
    expect(property.id).to eq('http://id.loc.gov/ontologies/bibframe/copyrightDate')
    expect(property.label).to eq('Copyright Date')
    expect(property.note).to eq('Include copyright symbol or use the term copyright.')
  end

  it 'maps literal property types' do
    property = property_for('http://id.loc.gov/ontologies/bibframe/title')
    expect(property.value_node_types).to eq(['LITERAL'])
  end

  it 'maps uri property types' do
    property = property_for('http://id.loc.gov/ontologies/bibframe/instanceOf')
    expect(property.value_node_types).to match_array(%w[LITERAL IRI])
  end

  it 'maps resource property types' do
    # attribute :value_node_types, Types::Array.of(Types::String.enum('IRI', 'LITERAL', 'BNODE'))
    property = property_for('http://id.loc.gov/ontologies/bibframe/identifiedBy')
    expect(property.value_node_types).to eq(['BNODE'])
    expect(property.value_shapes).to match_array(['ld4p:RT:bf2:Identifiers:LCCN', 'ld4p:RT:bf2:Identifiers:ISBN'])
  end

  it 'maps mandatory properties' do
    required_property = property_for('http://id.loc.gov/ontologies/bibframe/title')
    expect(required_property.mandatory).to be true

    not_required_property = property_for('http://id.loc.gov/ontologies/bibframe/copyrightDate')
    expect(not_required_property.mandatory).to be false
  end

  it 'maps repeatable properties' do
    repeatable_property = property_for('http://id.loc.gov/ontologies/bibframe/copyrightDate')
    expect(repeatable_property.repeatable).to be true

    not_repeatable_property = property_for('http://id.loc.gov/ontologies/bibframe/title')
    expect(not_repeatable_property.repeatable).to be false
  end

  it 'maps class property' do
    property = property_for('http://www.w3.org/1999/02/22-rdf-syntax-ns#type')
    expect(property.to_h).to match({
                                     id: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
                                     label: 'Class',
                                     mandatory: true,
                                     repeatable: false,
                                     value_node_types: [
                                       'IRI'
                                     ],
                                     value_constraint: 'http://id.loc.gov/ontologies/bibframe/Instance'
                                   })
  end

  it 'maps labeled resources' do
    property = property_for('http://id.loc.gov/ontologies/bibframe/instanceOf')
    expect(property.value_shapes).to eq(['sinopia:LabeledResource'])
  end

  def property_for(id)
    shape.properties.find { |property| property.id == id }
  end
end
