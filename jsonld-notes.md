# JSON-LD Notes

## JSON-LD API

### Context

The JSON-LD context appears to require that the mapping from JSON names to 
IRIs is unique, otherwise information is lost in the expand / compact or
serialization to RDF N-Quads, e.g. the following object:

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
   "age": 69
}
```
is serialized into RDF as:

```
_:b0 <http://www.w3.org/2001/XMLSchema#integer> "69"^^<http://www.w3.org/2001/XMLSchema#integer> .
_:b0 <http://www.w3.org/2001/XMLSchema#string> "Donald Trump" .
_:b0 <http://www.w3.org/2001/XMLSchema#string> "Real estate developer" .
```

So now is it difficult to distinguish `name` and `occupation` by inspecting the RDF N-Quads.
Also, the `xsd:integer` type has been assigned to both the predicate and the datatype appended 
to the object.

A more appropriate way to represent `name` and `occupation` might be:

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

Now each item can be queried based on the predicate.
## Use case for JSON-LD expansion / compaction APIs

## Testing a JSON-LD context for validity

