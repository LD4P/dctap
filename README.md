[![CircleCI](https://circleci.com/gh/LD4P/dctap.svg?style=svg)](https://circleci.com/gh/LD4P/dctap)

# dctap
A proof-of-concept Sinopia Profiles to [DCMI Tabular Application Profile](https://github.com/dcmi/dctap) (DCTAP) converter and Sinopia RDF validator using DCTAP profiles.


## Overview
One of the challenges for exchanging bibliographic metadata represented as RDF is variance in the "flavors" of shape of that metadata, even when following a specification such as BIBFRAME.

The goal of this library is to support the exchange of bibliographic metadata represented as RDF by:
* Providing a mapping from Sinopia Profiles to DCTAP to allow organizations to share profiles describing the shape of bibliographic metadata in a way that is human- and machine-readable.
* Providing a validation of conformance to DCTAP profiles for RDF records. (Note that this is not a generic DCTAP validator, but is specific to Sinopia DCTAP profiles.)

## Usage
### Generating DCTAP profiles
```
$ exe/sinopia2dctap -h
Usage: exe/sinopia2dctap [options] profile_id ...
    -u, --base_url BASE_URL          Base URL. Default is https://api.sinopia.io.
    -r, --recursive                  Recursive.
    -h, --help                       Displays help.

$ exe/sinopia2dctap -u https://api.development.sinopia.io -r sinopia:test:Monograph:Instance

$ ls shapes/
all_shapes.csv			  ld4p:RT:bf2:Identifiers:LCCN.csv  sinopia:LabeledResource.csv
ld4p:RT:bf2:Identifiers:ISBN.csv  ld4p:RT:bf2:Identifiers:Note.csv  sinopia:test:Monograph:Instance.csv

$ cat shapes/all_shapes.csv 
shapeID,shapeLabel,propertyID,propertyLabel,mandatory,repeatable,ordered,valueNodeType,valueConstraint,valueShape,note
sinopia:test:Monograph:Instance,Sinopia Test Instance (Monograph),http://www.w3.org/1999/02/22-rdf-syntax-ns#type,Class,true,false,,IRI,http://id.loc.gov/ontologies/bibframe/Instance,,
sinopia:test:Monograph:Instance,Sinopia Test Instance (Monograph),http://sinopia.io/vocabulary/hasResourceTemplate,Profile ID,false,false,,LITERAL,sinopia:test:Monograph:Instance,,
sinopia:test:Monograph:Instance,Sinopia Test Instance (Monograph),http://id.loc.gov/ontologies/bibframe/title,Title information,true,false,,LITERAL,,,
sinopia:test:Monograph:Instance,Sinopia Test Instance (Monograph),http://id.loc.gov/ontologies/bibframe/copyrightDate,Copyright Date,false,true,,LITERAL,,,Include copyright symbol or use the term copyright.
sinopia:test:Monograph:Instance,Sinopia Test Instance (Monograph),http://id.loc.gov/ontologies/bibframe/identifiedBy,Identifiers,false,true,,BNODE,,ld4p:RT:bf2:Identifiers:LCCN|ld4p:RT:bf2:Identifiers:ISBN,
sinopia:test:Monograph:Instance,Sinopia Test Instance (Monograph),http://id.loc.gov/ontologies/bibframe/instanceOf,Instance of,false,false,,LITERAL|IRI,,sinopia:LabeledResource,
sinopia:test:Monograph:Instance,Sinopia Test Instance (Monograph),http://id.loc.gov/ontologies/bibframe/note,Note about the instance,false,true,LIST,LITERAL,,,http://access.rdatoolkit.org/2.17.html
sinopia:LabeledResource,Labeled resource,http://www.w3.org/2000/01/rdf-schema#label,Label,false,false,,LITERAL,,,
ld4p:RT:bf2:Identifiers:LCCN,LCCN,http://www.w3.org/1999/02/22-rdf-syntax-ns#type,Class,true,false,,IRI,http://id.loc.gov/ontologies/bibframe/Lccn,,
ld4p:RT:bf2:Identifiers:LCCN,LCCN,http://sinopia.io/vocabulary/hasResourceTemplate,Profile ID,false,false,,LITERAL,ld4p:RT:bf2:Identifiers:LCCN,,
ld4p:RT:bf2:Identifiers:LCCN,LCCN,http://www.w3.org/1999/02/22-rdf-syntax-ns#value,LCCN,false,false,,LITERAL,,,
ld4p:RT:bf2:Identifiers:LCCN,LCCN,http://id.loc.gov/ontologies/bibframe/status,Invalid/Canceled?,false,true,,LITERAL|IRI,,sinopia:LabeledResource,
ld4p:RT:bf2:Identifiers:ISBN,ISBN,http://www.w3.org/1999/02/22-rdf-syntax-ns#type,Class,true,false,,IRI,http://id.loc.gov/ontologies/bibframe/Isbn,,
ld4p:RT:bf2:Identifiers:ISBN,ISBN,http://sinopia.io/vocabulary/hasResourceTemplate,Profile ID,false,false,,LITERAL,ld4p:RT:bf2:Identifiers:ISBN,,
ld4p:RT:bf2:Identifiers:ISBN,ISBN,http://www.w3.org/1999/02/22-rdf-syntax-ns#value,ISBN,false,false,,LITERAL,,,
ld4p:RT:bf2:Identifiers:ISBN,ISBN,http://id.loc.gov/ontologies/bibframe/qualifier,Qualifier,false,true,,LITERAL,,,
ld4p:RT:bf2:Identifiers:ISBN,ISBN,http://id.loc.gov/ontologies/bibframe/note,Note,false,true,,BNODE,,ld4p:RT:bf2:Identifiers:Note,
ld4p:RT:bf2:Identifiers:ISBN,ISBN,http://id.loc.gov/ontologies/bibframe/status,"Incorrect, Invalid or Canceled?",false,true,,LITERAL|IRI,,sinopia:LabeledResource,
ld4p:RT:bf2:Identifiers:Note,Note,http://www.w3.org/1999/02/22-rdf-syntax-ns#type,Class,true,false,,IRI,http://id.loc.gov/ontologies/bibframe/Note,,
ld4p:RT:bf2:Identifiers:Note,Note,http://sinopia.io/vocabulary/hasResourceTemplate,Profile ID,false,false,,LITERAL,ld4p:RT:bf2:Identifiers:Note,,
ld4p:RT:bf2:Identifiers:Note,Note,http://www.w3.org/2000/01/rdf-schema#label,Note text,false,true,,LITERAL,,,
```

### Validating conformance to DCTAP profiles
```
$ exe/validate -h
Usage: exe/validate [options] <resource url> || <resource filepath> <resource URI>
        --shape_id SHAPE_ID          Shape ID for validation.
    -s, --strict                     Strict. Unexpected properties are errors.
    -h, --help                       Displays help.

$ exe/validate https://api.development.sinopia.io/resource/b1e6898e-e0b5-4523-b50a-fbfab3ecaa23
Valid

$ exe/validate invalid.ttl https://api.development.sinopia.io/resource/b1e6898e-e0b5-4523-b50a-fbfab3ecaa23 --strict
Shape sinopia:test:Monograph:Instance
  Property http://id.loc.gov/ontologies/bibframe/title
    Error: Non-repeatable property is repeated.
  Property http://id.loc.gov/ontologies/bibframe/identifiedBy
    Value _:b18
      Shape ld4p:RT:bf2:Identifiers:LCCN
        Property http://www.w3.org/1999/02/22-rdf-syntax-ns#value
          Value http://id.loc.gov/vocabular/issn/2010919352
            Error: Incorrect node type.
  Property http://id.loc.gov/ontologies/bibframe/note
    Error: Not a list.
  Property http://id.loc.gov/ontologies/bibframe/contributor
    Error: Unexpected property.

```

Note that the shapes are read from the `shapes/` directory and must be generated before validation.