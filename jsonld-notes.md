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

[ this section not yet completed, not ready for review ]

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
