# JSON-LD Notes

## JSON-LD API

### Context Design Considerations

The JSON-LD API requires that each value in the context must
be an IRI. 

Also, the values defined appear much more useful if they
are unique in the context, i.e. represent unique concepts, otherwise data may 
be lost during the JSON-LD transformations available with the API.

The following example illustrates how information can be lost when a
document is serialized to RDF using a context that contains values 
that are not unique:

```
{
   "@context":
   {
      "xsd": "http://www.w3.org/2001/XMLSchema#",
      "name": "xsd:string",
      "occupation": "xsd:string",
      "age": "xsd:integer"
   },
   "name": "Donald Trump",
   "occupation": "Real estate developer",
   "age": 69,
   "politicalParty": "Republican"
}
```
is serialized into RDF as:

```
_:b0 <http://www.w3.org/2001/XMLSchema#integer> "69"^^<http://www.w3.org/2001/XMLSchema#integer> .
_:b0 <http://www.w3.org/2001/XMLSchema#string> "Donald Trump" .
_:b0 <http://www.w3.org/2001/XMLSchema#string> "Real estate developer" .
```

The serialized RDF makes it difficult to query for `name` and `occupation`. 

Also the `politicalParty` term is silently dropped because there is no entry for this name
in the context and it is not considered linked data by the JSON-LD API.

When this context / document are expanded then compacted, the resulting document now shows
two values for `name`, because the context is ambiguous regarding how to compact an `xsd:string`,
as it contains two mappings for this:
```
{
  "@context": {
    "xsd": "http://www.w3.org/2001/XMLSchema#",
    "name": "xsd:string",
    "occupation": "xsd:string",
    "age": "xsd:integer"
  },
  "age": 69,
  "name": [
    "Donald Trump",
    "Real estate developer"
  ]
}
```

A more appropriate way to represent `name` and `occupation` is to have 
unique mappings for these concepts using a context such as the 
following:

```
{    
  "@context": {"schema": "http://schema.org/",
               "xsd": "http://www.w3.org/2001/XMLSchema#",
               "name": {
                 "@id": "schema:name",
                 "@type": "xsd:string"
               },
               "occupation": {
                 "@id": "schema:occupation",
                 "@type": "xsd:string"
               }, 
               "age": {
                 "@id": "schema:age",
                 "@type": "xsd:integer"
               }
              },
              "name": "Donald Trump",
              "occupation": "Real estate developer",
              "age": 69
}

```

which is serialized to the following RDF:

```
_:b0 <http://schema.org/age> "69"^^<http://www.w3.org/2001/XMLSchema#integer> .
_:b0 <http://schema.org/name> "Donald Trump" .
_:b0 <http://schema.org/occupation> "Real estate developer" .
```

Now the `name` and `occupation` can be easily extracted with a query based on the predicate.

Also, when this document is expanded with the new context then compacted using the same context,
the equivalent of the original document is returned:

```
{
  "@context": {
    "schema": "http://schema.org/",
    "xsd": "http://www.w3.org/2001/XMLSchema#",
    "name": {
      "@id": "schema:name",
      "@type": "xsd:string"
    },
    "occupation": {
      "@id": "schema:occupation",
      "@type": "xsd:string"
    },
    "age": {
      "@id": "schema:age",
      "@type": "xsd:integer"
    }
  },
  "age": 69,
  "name": "Donald Trump",
  "occupation": "Real estate developer"
}
```

## Identifying Nodes

The JSON-LD keyword '@id' is used to associate an IRI with a JSON object
"Used to uniquely identify things that are being described in the document with IRIs or blank node identifiers."

When used within JSON-LD context, the `@id` keyword associates a name with an IRI:
```
{
   "@context":
   {
      "schema": "http://schema.org/",
      "person": "schema:Person",
      "affiliation": {
         "@id": "schema:affiliation"
      }
   },
  "person": "http://orcid.org/0000-0002-2192-403X",
  "affiliation": "NCEAS"
}
```

When expanded:
```
[
  {
    "http://schema.org/affiliation": [
      {
        "@value": "NCEAS"
      }
    ],
    "http://schema.org/Person": [
      {
        "@value": "http://orcid.org/0000-0002-2192-403X"
      }
    ]
  }
]
```

Serialized to RDF shows that `@id` used in the `@context` specifies the  
value the resulting RDF predicate:

```
_:b0 <http://schema.org/Person> "http://orcid.org/0000-0002-2192-403X" .
_:b0 <http://schema.org/affiliation> "NCEAS" .
```

When `@id` is used in the JSON-LD document, it will specify the identifier 
the RDF subject. as seen when the following document is serialized to RDF:

```
{
   "@context":
   {
      "schema": "http://schema.org/",
      "person": "schema:Person",
      "affiliation":"schema:affiliation",
      "address":"schema:address"
   },
  "person": "http://orcid.org/0000-0002-2192-403X",
  "affiliation": {
    "@id":"http://www.nceas.org",
    "address":"730 State Street, Santa Barbara, CA"
    
}
```

and the RDF:

```
<http://www.nceas.org> <http://schema.org/address> "730 State Street, Santa Barbara, CA" .
_:b0 <http://schema.org/Person> "http://orcid.org/0000-0002-2192-403X" .
_:b0 <http://schema.org/affiliation> <http://www.nceas.org> .
```

Notice that the `@id` specified in `@context` for `affiliation` has become the
subject in the RDF. If an `@id` is not assigned to a node in the graph in this way, then
a blank node identifier is automatically assinged:

```
{
   "@context":
   {
      "schema": "http://schema.org/",
      "person": "schema:Person",
      "affiliation":"schema:affiliation",
      "address":"schema:address"
   },
  "person": "http://orcid.org/0000-0002-2192-403X",
  "affiliation": {
    "address":"730 State Street, Santa Barbara, CA"
    
  }
}
```

is serialized to the RDF with `affiliation` now associated with a
blank node identifier:

```
_:b0 <http://schema.org/Person> "http://orcid.org/0000-0002-2192-403X" .
_:b0 <http://schema.org/affiliation> _:b1 .
_:b1 <http://schema.org/address> "730 State Street, Santa Barbara, CA" .
```

Notice that this usage of `@id` appears to be in effect by default, as the `person` term
that does not specify `@id` is serialized in the same fashion as `affilication` that does
specify `@id`.

```
  "@context":
  {
    "name": "http://schema.org/name",
    "image": {
      "@id": "http://schema.org/image",
      "@type": "@id"
    },
    "homepage": {
      "@id": "http://schema.org/url",
      "@type": "@id"
    }
  },
  "name": "Manu Sporny",
  "homepage": "http://manu.sporny.org/",
  "image": "http://manu.sporny.org/images/manu.png"
```

```
{
   "@context":
   {
      "name": "http://xmlns.com/foaf/0.1/name",
      "homepage": {
        "@id": "http://xmlns.com/foaf/0.1/homepage",
        "@type": "@id"
      }
   },
   "name": "Manu Sporny",
   "homepage": "http://manu.sporny.org/"
}
```

```
_:b0 <http://xmlns.com/foaf/0.1/homepage> <http://manu.sporny.org/> .
_:b0 <http://xmlns.com/foaf/0.1/name> "Manu Sporny" .
```

```
{
  "@context":
  {
    "name": "http://schema.org/name"
  },
  "@id": "http://me.markus-lanthaler.com/",
  "name": "Markus Lanthaler"
}

```
<http://me.markus-lanthaler.com/> <http://schema.org/name> "Markus Lanthaler" .
```
```
