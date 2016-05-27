# JSON-LD Notes

## JSON-LD API

### @context design considerations

The JSON-LD API makes it necessary to have unique mapping from JSON names to 
IRIs, otherwise information could be lost in the expand / compact or
serialization to Ntriples operations. Assume that we are defining a 
JSON-LD context where we wish to extract from a document someones name
and occupation. The context could be defined as shown in this JSON 
document:

```
{
   "@context":
   {
      "xsd": "http://www.w3.org/2001/XMLSchema#",
      "name": "xsd:string",
      "occupation": "xsd:string"
   },
   "name": "Donald Trump",
   "occupation": "President"
}
```
With the JSON-LD RDF serialization algorithm, the above document is transformed to
```
_:b0 <http://www.w3.org/2001/XMLSchema#string> "Donald Trump" .
_:b0 <http://www.w3.org/2001/XMLSchema#string> "President" .
```

With the resulting RDF, it is not possible to distinguish `name` from `occupation`.

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
                 "@type": "xsd:string"}
              },
               "name": "Donald Trump",
               "occupation": "President"
}

```

which is RDF serialized to:

```
_:b0 <http://schema.org/name> "Donald Trump" .
_:b0 <http://schema.org/occupation> "President" .
```

Not sure why the JSON-LD RDF serialization doesn't append `^^http://www.w3.org/2001/XMLSchema/string`
to the objects, maybe this is an RDF convention that the serializer is following.

## Use case for JSON-LD expansion / compaction APIs

## Testing a JSON-LD context for validity

