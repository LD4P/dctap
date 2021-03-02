# frozen_string_literal: true

RSpec.describe Profiles::Dctap::Validator do
  let(:report) { described_class.validate(RDF::URI.new(subject), shape_id, graph, shapes, strict: strict) }

  let(:subject) { 'https://api.sinopia.io/resource/70ac2ed7' }

  let(:shape_id) { 'pcc:bf2:Monograph:Instance' }

  let(:strict) { true }

  let(:shapes) do
    [
      Profiles::Dctap::Models::Shape.new({
                                           id: 'pcc:bf2:Monograph:Instance',
                                           properties: [{
                                             id: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
                                             mandatory: true,
                                             value_node_types: ['IRI'],
                                             value_constraint: 'http://id.loc.gov/ontologies/bibframe/Instance'
                                           },
                                                        {
                                                          id: 'http://id.loc.gov/ontologies/bibframe/issuance',
                                                          value_node_types: ['IRI'],
                                                          value_shapes: ['sinopia:LabeledResource']
                                                        },
                                                        {
                                                          id: 'http://id.loc.gov/ontologies/bibframe/editionStatement',
                                                          value_node_types: ['LITERAL']
                                                        },
                                                        {
                                                          id: 'http://id.loc.gov/ontologies/bibframe/identifiedBy',
                                                          repeatable: true,
                                                          value_node_types: ['BNODE'],
                                                          value_shapes: ['pcc:bf2:Identifiers:LCCN',
                                                                         'pcc:bf2:Identifiers:ISBN']
                                                        },
                                                        {
                                                          id: 'http://id.loc.gov/ontologies/bibframe/title',
                                                          value_node_types: ['LITERAL'],
                                                          ordered: 'LIST'
                                                        }]
                                         }),
      Profiles::Dctap::Models::Shape.new({
                                           id: 'pcc:bf2:Identifiers:LCCN',
                                           properties: [
                                             {
                                               id: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
                                               mandatory: true,
                                               value_node_types: ['IRI'],
                                               value_constraint: 'http://id.loc.gov/ontologies/bibframe/Lccn'
                                             },
                                             {
                                               id: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#value',
                                               value_node_types: ['LITERAL']
                                             }
                                           ]
                                         }),
      Profiles::Dctap::Models::Shape.new({
                                           id: 'pcc:bf2:Identifiers:ISBN',
                                           properties: [
                                             {
                                               id: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
                                               mandatory: true,
                                               value_node_types: ['IRI'],
                                               value_constraint: 'http://id.loc.gov/ontologies/bibframe/Isbn'
                                             },
                                             {
                                               id: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#value',
                                               value_node_types: ['LITERAL']
                                             }
                                           ]
                                         }),
      Profiles::Dctap::Models::Shape.new({
                                           id: 'sinopia:LabeledResource',
                                           properties: [
                                             {
                                               id: RDF::RDFS.label.value,
                                               value_node_types: ['LITERAL']
                                             }
                                           ]
                                         })
    ]
  end

  let(:graph) { RDF::Graph.new.from_ttl(ttl) }

  context 'when unknown shape' do
    let(:shape_id) { 'pcc:bf2:Monograph:Work' }

    let(:ttl) do
      <<~TTL
        <#{subject}> a <http://id.loc.gov/ontologies/bibframe/Work>.
      TTL
    end

    it 'reports error' do
      expect(report.valid?).to be(false)
      expect(report).to have_shape_error(Profiles::Dctap::Models::ShapeReport::UNKNOWN_SHAPE)
    end
  end

  context 'when mandatory property' do
    context 'is present' do
      let(:ttl) do
        <<~TTL
          <#{subject}> a <http://id.loc.gov/ontologies/bibframe/Instance>.
        TTL
      end

      it 'is valid' do
        expect(report.valid?).to be(true)
      end
    end

    context 'is missing' do
      let(:ttl) do
        <<~TTL
        TTL
      end

      it 'reports error' do
        expect(report.valid?).to be(false)
        expect(report).to have_property_error('http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
                                              Profiles::Dctap::Models::PropertyReport::MANDATORY_PROPERTY_MISSING)
      end
    end
  end

  context 'when non-repeatable property' do
    context 'is not repeated' do
      let(:ttl) do
        <<~TTL
          <#{subject}> a <http://id.loc.gov/ontologies/bibframe/Instance>.
        TTL
      end

      it 'is valid' do
        expect(report.valid?).to be(true)
      end
    end

    context 'is repeated' do
      let(:ttl) do
        <<~TTL
          <#{subject}> a <http://id.loc.gov/ontologies/bibframe/Instance>;
            a <http://id.loc.gov/ontologies/bibframe/Item>.
        TTL
      end

      it 'reports error' do
        expect(report.valid?).to be(false)
        expect(report).to have_property_error('http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
                                              Profiles::Dctap::Models::PropertyReport::REPEATED_ERROR)
      end
    end
  end

  context 'when IRI node' do
    context 'is an IRI' do
      let(:ttl) do
        <<~TTL
          <#{subject}> a <http://id.loc.gov/ontologies/bibframe/Instance>;
            <http://id.loc.gov/ontologies/bibframe/issuance> <http://id.loc.gov/vocabulary/issuance/mono>.
        TTL
      end

      it 'is valid' do
        expect(report.valid?).to be(true)
      end
    end

    context 'is a literal' do
      let(:ttl) do
        <<~TTL
          <#{subject}> a <http://id.loc.gov/ontologies/bibframe/Instance>;
            <http://id.loc.gov/ontologies/bibframe/issuance> "single unit".
        TTL
      end

      it 'reports error' do
        expect(report.valid?).to be(false)
        expect(report).to have_value_error('http://id.loc.gov/ontologies/bibframe/issuance',
                                           'single unit',
                                           Profiles::Dctap::Models::ValueReport::INCORRECT_NODE_TYPE)
      end
    end

    context 'is a blank node' do
      let(:ttl) do
        <<~TTL
          <#{subject}> a <http://id.loc.gov/ontologies/bibframe/Instance>;
            <http://id.loc.gov/ontologies/bibframe/issuance> _:b33.
        TTL
      end

      it 'reports error' do
        expect(report.valid?).to be(false)
        expect(report).to have_value_error('http://id.loc.gov/ontologies/bibframe/issuance',
                                           '_:b33',
                                           Profiles::Dctap::Models::ValueReport::INCORRECT_NODE_TYPE)
      end
    end
  end

  context 'when literal node' do
    context 'is an IRI' do
      let(:ttl) do
        <<~TTL
          <#{subject}> a <http://id.loc.gov/ontologies/bibframe/Instance>;
            <http://id.loc.gov/ontologies/bibframe/editionStatement> <http://id.loc.gov/vocabulary/edition/first>.
        TTL
      end

      it 'reports error' do
        expect(report.valid?).to be(false)
        expect(report).to have_value_error('http://id.loc.gov/ontologies/bibframe/editionStatement',
                                           'http://id.loc.gov/vocabulary/edition/first',
                                           Profiles::Dctap::Models::ValueReport::INCORRECT_NODE_TYPE)
      end
    end

    context 'is a literal' do
      let(:ttl) do
        <<~TTL
          <#{subject}> a <http://id.loc.gov/ontologies/bibframe/Instance>;
            <http://id.loc.gov/ontologies/bibframe/editionStatement> "First edition"@eng.
        TTL
      end

      it 'is valid' do
        expect(report.valid?).to be(true)
      end
    end

    context 'is a blank node' do
      let(:ttl) do
        <<~TTL
          <#{subject}> a <http://id.loc.gov/ontologies/bibframe/Instance>;
            <http://id.loc.gov/ontologies/bibframe/editionStatement> _:b33.
        TTL
      end

      it 'reports error' do
        expect(report.valid?).to be(false)
        expect(report).to have_value_error('http://id.loc.gov/ontologies/bibframe/editionStatement',
                                           '_:b33',
                                           Profiles::Dctap::Models::ValueReport::INCORRECT_NODE_TYPE)
      end
    end
  end

  context 'when blank node node' do
    context 'is an IRI' do
      let(:ttl) do
        <<~TTL
          <#{subject}> a <http://id.loc.gov/ontologies/bibframe/Instance>;
            <http://id.loc.gov/ontologies/bibframe/identifiedBy> <http://id.loc.gov/vocabulary/lccn/84047628>.
        TTL
      end

      it 'reports error' do
        expect(report.valid?).to be(false)
        expect(report).to have_value_error('http://id.loc.gov/ontologies/bibframe/identifiedBy',
                                           'http://id.loc.gov/vocabulary/lccn/84047628',
                                           Profiles::Dctap::Models::ValueReport::INCORRECT_NODE_TYPE)
      end
    end

    context 'is a literal' do
      let(:ttl) do
        <<~TTL
          <#{subject}> a <http://id.loc.gov/ontologies/bibframe/Instance>;
            <http://id.loc.gov/ontologies/bibframe/identifiedBy> "84047628".
        TTL
      end

      it 'reports error' do
        expect(report.valid?).to be(false)
        expect(report).to have_value_error('http://id.loc.gov/ontologies/bibframe/identifiedBy',
                                           '84047628',
                                           Profiles::Dctap::Models::ValueReport::INCORRECT_NODE_TYPE)
      end
    end

    context 'is a blank node' do
      let(:ttl) do
        <<~TTL
          <#{subject}> a <http://id.loc.gov/ontologies/bibframe/Instance>;
            <http://id.loc.gov/ontologies/bibframe/identifiedBy> _:b33.
          _:b33 a <http://id.loc.gov/ontologies/bibframe/Lccn>;
            <http://www.w3.org/1999/02/22-rdf-syntax-ns#value> '2010919352'.
        TTL
      end

      it 'is valid' do
        expect(report.valid?).to be(true)
      end
    end
  end

  context 'when property has value constraint' do
    context 'constraint matches' do
      let(:ttl) do
        <<~TTL
          <#{subject}> a <http://id.loc.gov/ontologies/bibframe/Instance>.
        TTL
      end

      it 'is valid' do
        expect(report.valid?).to be(true)
      end
    end

    context 'constraint does not match' do
      let(:ttl) do
        <<~TTL
          <#{subject}> a <http://id.loc.gov/ontologies/bibframe/Work>.
        TTL
      end

      it 'reports error' do
        expect(report.valid?).to be(false)
        expect(report).to have_value_error('http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
                                           'http://id.loc.gov/ontologies/bibframe/Work',
                                           Profiles::Dctap::Models::ValueReport::VALUE_CONSTRAINT_MISMATCH)
      end
    end
  end

  context 'when property is ordered' do
    context 'with a list' do
      let(:ttl) do
        <<~TTL
          <#{subject}> a <http://id.loc.gov/ontologies/bibframe/Instance>;
            <http://id.loc.gov/ontologies/bibframe/title> _:b172.
          _:b172 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil>;
            <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "Non-Technical Canyon Guide"@eng.
        TTL
      end

      it 'is valid' do
        expect(report.valid?).to be(true)
      end
    end

    context 'without a list' do
      let(:ttl) do
        <<~TTL
          <#{subject}> a <http://id.loc.gov/ontologies/bibframe/Work>;
            <http://id.loc.gov/ontologies/bibframe/title> "Non-Technical Canyon Guide".
        TTL
      end

      it 'reports error' do
        expect(report.valid?).to be(false)
        expect(report).to have_property_error('http://id.loc.gov/ontologies/bibframe/title',
                                              Profiles::Dctap::Models::PropertyReport::NOT_LIST)
      end
    end
  end

  context 'when property has value shapes' do
    context 'matches value shapes' do
      let(:ttl) do
        <<~TTL
          <#{subject}> a <http://id.loc.gov/ontologies/bibframe/Instance>;
            <http://id.loc.gov/ontologies/bibframe/identifiedBy> _:b33;
            <http://id.loc.gov/ontologies/bibframe/identifiedBy> _:b34.
          _:b33 a <http://id.loc.gov/ontologies/bibframe/Lccn>;
            <http://www.w3.org/1999/02/22-rdf-syntax-ns#value> '2010919352'.
          _:b34 a <http://id.loc.gov/ontologies/bibframe/Isbn>;
            <http://www.w3.org/1999/02/22-rdf-syntax-ns#value> '9780944510278'.
        TTL
      end

      it 'is valid' do
        expect(report.valid?).to be(true)
      end
    end

    context 'missing class' do
      let(:ttl) do
        <<~TTL
          <#{subject}> a <http://id.loc.gov/ontologies/bibframe/Instance>;
            <http://id.loc.gov/ontologies/bibframe/identifiedBy> _:b33.
          _:b33 <http://www.w3.org/1999/02/22-rdf-syntax-ns#value> '2010919352'.
        TTL
      end

      it 'reports error' do
        expect(report.valid?).to be(false)
      end
    end

    context 'missing shape' do
      let(:ttl) do
        <<~TTL
          <#{subject}> a <http://id.loc.gov/ontologies/bibframe/Instance>;
            <http://id.loc.gov/ontologies/bibframe/identifiedBy> _:b33.
          _:b33 a <http://id.loc.gov/ontologies/bibframe/Local>;
            <http://www.w3.org/1999/02/22-rdf-syntax-ns#value> '2010919352'.
        TTL
      end

      it 'reports error' do
        expect(report.valid?).to be(false)
      end
    end

    context 'does not match value shape' do
      let(:ttl) do
        <<~TTL
          <#{subject}> a <http://id.loc.gov/ontologies/bibframe/Instance>;
            <http://id.loc.gov/ontologies/bibframe/identifiedBy> _:b33.
          _:b33 a <http://id.loc.gov/ontologies/bibframe/Lccn>;
            <http://www.w3.org/1999/02/22-rdf-syntax-ns#value> <http://id.loc.gov/vocabulary/lccn/2010919352>.
        TTL
      end

      it 'reports error' do
        expect(report.valid?).to be(false)
      end
    end
  end

  context 'when property has single value shape' do
    context 'matches value shape' do
      let(:ttl) do
        <<~TTL
          <#{subject}> a <http://id.loc.gov/ontologies/bibframe/Instance>;
            <http://id.loc.gov/ontologies/bibframe/issuance> <http://id.loc.gov/vocabulary/issuance/mono>.
          <http://id.loc.gov/vocabulary/issuance/mono> <http://www.w3.org/2000/01/rdf-schema#label> "single unit".
        TTL
      end

      it 'is valid' do
        expect(report.valid?).to be(true)
      end
    end

    context 'does not match value shape' do
      let(:ttl) do
        <<~TTL
          <#{subject}> a <http://id.loc.gov/ontologies/bibframe/Instance>;
            <http://id.loc.gov/ontologies/bibframe/issuance> <http://id.loc.gov/vocabulary/issuance/mono>.
          <http://id.loc.gov/vocabulary/issuance/mono> <http://www.w3.org/2000/01/rdf-schema#label> <http://id.loc.gov/vocabulary/issuance/mono>.
        TTL
      end

      it 'reports error' do
        expect(report.valid?).to be(false)
      end
    end
  end

  context 'when extra properties' do
    let(:ttl) do
      <<~TTL
        <#{subject}> a <http://id.loc.gov/ontologies/bibframe/Instance>;
          <http://id.loc.gov/ontologies/bibframe/copyrightDate> "2019"@eng.
      TTL
    end

    context 'when strict' do
      it 'reports error' do
        expect(report.valid?).to be(false)
        expect(report).to have_property_error('http://id.loc.gov/ontologies/bibframe/copyrightDate',
                                              Profiles::Dctap::Models::PropertyReport::UNEXPECTED_PROPERTY)
      end
    end

    context 'when strict' do
      let(:strict) { false }

      it 'is valid when not strict' do
        expect(report.valid?).to be(true)
      end
    end
  end
end
