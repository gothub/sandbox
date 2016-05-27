# JSON-LD Notes

## JSON-LD API

### Context

The JSON-LD API makes it necessary to have unique mapping from JSON names to 
IRIs, otherwise information could be lost in the expand / compact or
transformation to Ntriples operations, e.g. the following object:

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
is transformed to
```
_:b0 <http://www.w3.org/2001/XMLSchema#string> "Donald Trump" .
_:b0 <http://www.w3.org/2001/XMLSchema#string> "President" .
```

With the resulting RDF, it is not possible determine the values for
`name` and `occupation`.

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

which is transfored to:

```
_:b0 <http://schema.org/name> "Donald Trump" .
_:b0 <http://schema.org/occupation> "President" .
```

Not sure why the JSON-LD RDF serialization doesn't append `^^http://www.w3.org/2001/XMLSchema/string`
to the objects, maybe this is an RDF convention to not append this if the value is enclosed
in quotes.

