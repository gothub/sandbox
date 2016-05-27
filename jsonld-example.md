# Context:

ruby snippet:

```
context = JSON.parse(File.read('simple-context.jsonld'))['@context']
```

```
{
        "schema" => "http://schema.org/",
          "name" => "schema:Text",
    "occupation" => "schema:Text"
}
```

# Input document

```
    input = JSON.parse(File.read('example.json'))
```

input value:

```
{
      "@context" => "https://raw.githubusercontent.com/gothub/sbpcssndbox/master/simple-context.jsonld",
          "name" => "Donald Trump",
    "occupation" => "President"
}
```

# Expanded

```
expanded = JSON::LD::API.expand(input)
```

```
[
    {
        "http://schema.org/Text" => [
            {
                "@value" => "Donald Trump"
            },
            {
                "@value" => "President"
            }
        ]
    }
]
```

# Compacted

```
    compacted =  JSON::LD::API.compact(expanded, context)
```

```
{
    "@context" => {
            "schema" => "http://schema.org/",
              "name" => "schema:Text",
        "occupation" => "schema:Text"
    },
        "name" => [
        "Donald Trump",
        "President"
    ]
}
```
